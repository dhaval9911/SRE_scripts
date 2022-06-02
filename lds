read -p "Stackname: " stack

#open all basic dashboards needed for given stack name 

#CO2
open -a "Google Chrome" "https://web.co2.lve.splunkcloud.systems/stack/info/$stack/status"

# stack overview
open -a "Google Chrome" "https://skynet-search.splunkcloud.com/en-GB/app/cloudops/stack_overview?form.stack=$stack"

# stack precheck dashboard
open -a "Google Chrome" "https://skynet-search.splunkcloud.com/en-GB/app/cloudops/stack_prechecks?form.packageid=*&form.uid=*&form.spec=metadata&form.stack=$stack"

#puppet
open -a "Google Chrome" "https://puppet-master.lve.splunkcloud.systems/#/enforcement/status"

# grep jenkins from cloudctl stacks get
open -a "Google Chrome" $(cloudctl stacks get $stack  | grep jenkins | awk '{print $2}')


#Signal FX
open -a "Google Chrome" "https://app.us2.signalfx.com/#/alerts?groupBy=stack&sources%5B%5D=stack:$stack"

#open CM ui and print CM creds
echo "-------------  CM --------------- \n" 
vault read cloud-sec-lve-ephemeral/creds/$stack-admin/$(nslookup c0m.$stack.splunkcloud.com | awk '{print $1}' | grep ".-i-" ) | egrep 'username|password' 
open -a "Google Chrome" "https://c0m1.$stack.splunkcloud.com:8443/en-US/account/login?loginType=Splunk"
echo " \n "

#open SH1 ui and print SH1 creds
echo "-------------- SH1 -------------- \n" 
vault read cloud-sec-lve-ephemeral/creds/$stack-admin/$(nslookup sh1.$stack.splunkcloud.com | awk '{print $1}' | grep ".-i-") | egrep 'username|password' 
open -a "Google Chrome" "https://sh1.$stack.splunkcloud.com/en-US/account/login?loginType=Splunk" 
echo " \n "

#open SH1 ui and print IDM1 creds
echo "-------------- IDM1 -------------- \n" 
vault read cloud-sec-lve-ephemeral/creds/$stack-admin/$(nslookup idm1.$stack.splunkcloud.com | awk '{print $1}' | grep ".-i-") | egrep 'username|password' 
open -a "Google Chrome" "https://idm1.$stack.splunkcloud.com/en-US/account/login?loginType=Splunk" 
echo " \n "

#admin creds
echo "--------------- ADMIN ------------- \n "
vault kv get cloud-sec/std/lve/stacks/$stack/admin | egrep 'plaintext|version'
echo " \n "



