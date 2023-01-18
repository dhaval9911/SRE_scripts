import argparse
from datetime import date
import http
import json
import os
import sys
import time
import subprocess
from unicodedata import name
import uuid
import warnings
from getpass import getpass, getuser
from urllib.parse import parse_qs, urlparse
import jwt
import requests
import re
from pathlib import Path
from bs4 import BeautifulSoup
from jira.client import JIRA

warnings.filterwarnings(action="ignore", category=ResourceWarning)
warnings.filterwarnings(action='ignore', message='Unverified HTTPS request')

parser = argparse.ArgumentParser()

parser.add_argument('-s', '--stack',
                    help='Stack name (Example: fedexservices,nike,pacificlife)',
                    required=True)

parser.add_argument('-j', '--jira',
                    help='Jira ticket (Example: TO-16301,TO-16302)',
                    required=True)


AD_USER = getuser()
SHELL_PATH = os.environ['PATH']
HOME_PATH = os.environ['HOME']
print("Your username is " + AD_USER)


JIRA_SERVER = "https://splunk.atlassian.net"
args = parser.parse_args()

# Arguments
STACK = args.stack
# Strings
POST_DOMAIN = ".splunkcloud.com"
SPLUNKBASE_URL = "https://splunkbase.splunk.com/app/"
CO2_ENV = ""
VAULT_TOKEN = ""
SHC_MEMBER = ""
ADMIN_VAULT_PASS = ""
# JIRA_ID = "DHAVAL"


if args.jira is not None:
    JIRA_ID = args.jira

VAULT_ADDR = "https://vault.splunkcloud.systems"
VAULT_PATH = "/v1/cloud-sec-lve-ephemeral/creds/"

AD_PASSWORD = getpass(prompt='Enter your AD_PASSWORD: ', stream=None)

OKTA_PASSWORD = getpass(
    prompt='OKTA_PASSWORD (If it is the same as AD_PASSWORD, just press Enter): ', stream=None)

if OKTA_PASSWORD == '':
    OKTA_PASSWORD = AD_PASSWORD
       
# read JIRA_TOKEN from ~/.jira/token file

JIRA_TOKEN = ""
try:
    with open('/Users/' + AD_USER + '/.jira/token', "r") as jira_token_read:
        JIRA_TOKEN = jira_token_read.read().strip()
except FileNotFoundError as fe:
    JIRA_TOKEN = getpass(prompt='Enter your JIRA_TOKEN: ', stream=None)
    if ".jira" not in os.listdir('/Users/' + AD_USER):
        os.mkdir('/Users/' + AD_USER + '/.jira/')
    with open('/Users/' + AD_USER + '/.jira/token', "w") as jira_token_write:
        jira_token_write.write(JIRA_TOKEN)

EMAIL_ID = (AD_USER + '@splunk.com')


if POST_DOMAIN == ".splunkcloud.com":
    CO2_ENV = "prod"
    CO2APIENDPOINT = "https://api.co2.lve.splunkcloud.systems"
    
try:
    setEnv = str(os.popen('cloudctl config use ' +
                    CO2_ENV + ' 2>&1').read())
except Exception as e:
    print(e)
    
print("CO2 Configuration:\n" + setEnv + "##########")

def co2_check_token():
    token_file = HOME_PATH + '/.cloudctl/token_' + CO2_ENV
    try:
        if os.path.exists(token_file):
            if os.path.getsize(token_file) > 0:
                with open(token_file, 'r') as content_file:
                    token = content_file.read()
                decodedToken = jwt.decode(
                    token, options={"verify_signature": False})
                jsonToken = json.dumps(decodedToken)
                tokenExpireTime = json.loads(jsonToken)["exp"]
                currentTime = int(time.strftime("%s"))
                difference = tokenExpireTime - currentTime
                if difference > 60:
                    return True

    except Exception as e:
        print(e)

    return False


def get_token():
  f = open(str(Path.home())+"/.cloudctl/token_"+ CO2_ENV, "r")
  return f.read()


def co2_login():
    while co2_check_token() is not True:
        token_file = HOME_PATH + '/.cloudctl/token_' + CO2_ENV 
        print("SplunkCloud: Logging into CO2")

        try:
            header = {'Accept': 'application/json',
                      'Content-Type': 'application/json', 'Cache-Control': 'no-cache'}
            login_url = "https://splunkcloud.okta.com/api/v1/authn"
            login_payload = {'username': AD_USER, 'password': AD_PASSWORD}

            login_response = requests.post(
                login_url, headers=header, json=login_payload)

            if login_response.status_code != 200:
                raise Exception()

            login_response_json = json.loads(login_response.text)
            stateToken = str(login_response_json['stateToken'])
            push_verification_link = str(
                login_response_json['_embedded']['factors'][0]['_links']['verify']['href'])

            push_url = push_verification_link
            push_payload = {'stateToken': stateToken}
            push_response_json = ''

            while True:
                push_response = requests.post(
                    push_url, headers=header, json=push_payload)

                if push_response.status_code != 200:
                    raise Exception()

                push_response_json = json.loads(push_response.text)
                auth_status = str(push_response_json['status'])

                if auth_status == "SUCCESS":
                    break

                time.sleep(0.5)

            session_token = str(push_response_json['sessionToken'])

            with open(HOME_PATH + "/.cloudctl/config.yaml", 'r') as cloudctl_config:
                configs = cloudctl_config.readlines()

            for config in configs:

                if "idpclientid" in config:
                    client_id = config.split(": ")[1].rstrip('\n')

                if "idpserverid" in config:
                    server_id = config.split(": ")[1].rstrip('\n')

            access_token_url = "https://splunkcloud.okta.com/oauth2/" + server_id + "/v1/authorize?client_id=" + client_id + "&nonce=" + str(uuid.uuid4()) + \
                "&prompt=none&redirect_uri=https%3A%2F%2Fdoes.not.resolve%2F&response_type=token&scope=&sessionToken=" + \
                session_token + "&state=not.used"
            access_token_response = requests.get(
                access_token_url, allow_redirects=False)

            if access_token_response.status_code != 302:
                raise Exception()

            parsed_access_token_header = urlparse(
                access_token_response.headers['location'])
            access_token = parse_qs(parsed_access_token_header.fragment)[
                'access_token'][0]

            with open(token_file, 'w') as token_f:
                token_f.write(access_token)

        except Exception as e:
            print("\nSplunkCloud: Failed to log into CO2\n" + e)


try:
    co2_login()
    
except Exception as e:
    print(e)
    quit()

# QUERY YES OR NOT

def query_yes_no(question, default="no"):
    valid = {"yes": True, "y": True, "ye": True, "no": False, "n": False}
    if default is None:
        prompt = " [y/n] "
    elif default == "yes":
        prompt = " [Y/n] "
    elif default == "no":
        prompt = " [y/N] "
    else:
        raise ValueError("invalid default answer: '%s'" % default)
    while True:
        sys.stdout.write(question + prompt)
        choice = input().lower()
        if default is not None and choice == '':
            return valid[default]
        elif choice in valid:
            return valid[choice]
        else:
            sys.stdout.write(
                "Please respond with 'yes' or 'no' (or 'y' or 'n').\n")



# series= ['01', '02']
series= ['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12', '13', '14', '15', 'instructor']
global JIRA_CMT_STR
JIRA_CMT_STR=" "


def s2_buckets():
     print("\n\n")
     global JIRA_CMT_STR
     JIRA_CMT_STR+= "h2. s2 Buckets For " + STACK + "\n"  
     for i in series:
        cmd="cloudctl stacks get " + STACK + "-" + i + " | grep '\:\ss2-object' | sed 's/s2_bucket_name\://g' | sed 's/ ^*//g' "
        JIRA_CMT_STR+="\n" + STACK + "-" + i + "\n"
        JIRA_CMT_STR+=(os.popen(cmd).read())
        print("Waiting For   " + STACK + "-" + i)


def jenkins():
    global JIRA_CMT_STR
    print("h2. Jenkins For " + STACK + "-" + i)
    for i in series:
        cmd="cloudctl stacks get " + STACK + "-" + i + " | grep jenkins"
        JIRA_CMT_STR+="\n" + STACK + "-" + i + "\n"
        JIRA_CMT_STR+=(os.popen(cmd).read().strip(" \n'lastProvisionedURL\:'") + "console")




def first_step():
    global JIRA_CMT_STR
    for i in series:
        cmd="cloudctl stacks delete " + STACK + "-" + i + " --reason \"" + JIRA_ID + " Terminate Stack \"" 
        JIRA_CMT_STR+="\n" + STACK + "-" + i + "\n"
        JIRA_CMT_STR+=(os.popen(cmd).read())
        cmd="cloudctl stacks get " + STACK + "-" +  i +   " | grep ^version | sed s/version\://g  | sed 's/ ^*//g' "
        cmd=(os.popen(cmd).read())
        version_one=int(cmd)
        version_new=(version_one + 1)
        JIRA_CMT_STR+="https://console.splunkcloud.system/lve/stack/" + STACK + "-" + i + "/diff/" + str(version_one) + "/" + str(version_new)  + "\n"


def open_all_sh():
    for i in series:
        cmd="open -a \"Google Chrome\" \"https://sh1." + STACK + "-" + i + ".splunkcloud.com\""
        cmd=(os.popen(cmd).read)
        cmd()




def get_version():
    print("\n\n")
    for i in series:
        global JIRA_CMT_STR
        cmd="cloudctl stacks get " + STACK + "-" + i  + " | grep ^version"
        version=(os.popen(cmd).read())
        version=int(str(version).strip("version\: \n"))
        version2=version - 1
        print(STACK  + "-" +  i)
        print("https://web.co2.lve.splunkcloud.systems/lve/stack/"  +  STACK  + "-" +  i  + "/diff/" +  str(version2) +  "/" + str(version))



def remove_mw():
    print("\n\n")
    for i in series:
     global JIRA_CMT_STR
     cmd="cloudctl stacks get -o json " + STACK + "-" + i  + "> " + STACK + "-" + i  + ".json"
     os.popen(cmd).read()
     name=STACK + "-" + i +  '.json'
     f = open(name)
     data = json.load(f)
     del data["spec"]["maintenanceWindow"]
     del data["spec"]["platformSettings"]["foo"]
     data = str(data)
     with open(STACK + "-" + i + '.json' , 'w') as token_f:
          token_f.write(data)
     cmd = "cloudctl stacks update  -o json " + STACK + "-" + i  + " -f " + STACK + "-" + i  + ".json --reason \"" + JIRA_ID + " remove MW.\" " 
     JIRA_CMT_STR+="\n" + STACK + "-" + i + "\n"
     JIRA_CMT_STR+=(os.popen(cmd).read())   
     JIRA_CMT_STR+="https://web.co2.lve.splunkcloud.systems/lve/stack/"  +  STACK + "-" + i  + "/proposal"
     os.remove(name)



def add_mw():
    print("\n\n")
    for i in series:
     global JIRA_CMT_STR
     cmd="cloudctl stacks get -o json " + STACK + "-" + i  + " > " + STACK + "-" + i  + ".json"
     os.popen(cmd).read()
     name=STACK + "-" + i +  '.json'
     f = open(name)
     data = json.load(f)
     data['spec']['maintenanceWindow'].update( {  "ranges": [  {  "duration": "23h59m", "startTime": "00:00"  }  ] })
     data = str(data)
     with open(STACK + "-" + i + '.json' , 'w') as token_f:
          token_f.write(data)
     cmd = "cloudctl stacks update " + STACK + "-" + i  + " -f " + STACK + "-" + i  + ".json --reason  \"" + JIRA_ID + " add MW.\" " 
     JIRA_CMT_STR+="\n" + STACK + "-" + i + "\n"
     JIRA_CMT_STR+=(os.popen(cmd).read())
     os.remove(name)


def add_foo_bar():
    print("\n\n")
    for i in series:
     global JIRA_CMT_STR
     cmd="cloudctl stacks get -o json " + STACK + "-" + i  + " > " + STACK + "-" + i  + ".json"
     os.popen(cmd).read()
     name=STACK + "-" + i +  '.json'
     f = open(name)
     data = json.load(f)
     data['spec'].update({ "platformSettings":  { "foo": "bar"  } } )
     data = str(data)
     with open(STACK + "-" + i + '.json' , 'w') as token_f:
          token_f.write(data)
     cmd = "cloudctl stacks update " + STACK + "-" + i  + " -f " + STACK + "-" + i  + ".json --reason  \"" + JIRA_ID + " add Foo/Bar.\" " 
     os.popen(cmd).read()
     JIRA_CMT_STR+="\n" + STACK + "-" + i + "\n"
     JIRA_CMT_STR+="https://web.co2.lve.splunkcloud.systems/lve/stack/"  +  STACK + "-" + i  + "/proposal"
     os.remove(name)


def print_comment():
    print(JIRA_CMT_STR)
    if query_yes_no("\n\nDo you want to add JIRA comment?", "yes"):     
        options = {'server': JIRA_SERVER}
        jira = JIRA(options=options, basic_auth=(EMAIL_ID, JIRA_TOKEN))
        issue = jira.issue(JIRA_ID)
        jira.add_comment(issue, JIRA_CMT_STR)
        print("Comment added successfully: " +
            JIRA_SERVER + "/browse/" + JIRA_ID)  


user_input = ''



print(JIRA_ID)
while True:
    user_input = input(
        '\n Pick one action for ' + STACK + ' \n \n (1) Jenkins \n (2) s2 Buckets \n (3) Remove MW  & Foo/Bar \n (4) Add MW \n (5) First Step PR \n (6) Open All SHs UI \n (7) Add Foo/Bar \n (8) Exit\n \n ~:   ')
    if user_input == '1':
        jenkins()
        print_comment()
        continue
    if user_input == '2':
        s2_buckets()
        print_comment()
        continue
    elif user_input == '3':
        remove_mw()
        print_comment()
        continue
    elif user_input == '4':
        add_mw()
        print_comment()
        continue
    elif user_input == '5':
        first_step()
        print_comment()
        continue
    elif user_input == '6':
        open_all_sh()
        continue
    elif user_input == '7':
        add_foo_bar()
        continue
    elif user_input == '8':
        break
    