#!/bin/bash


# Input file
FILE=~/.vault-token
#Get Current File age in Minutes 
FILEAGE=$(perl -e 'printf "%d\n" ,(time()-((stat(shift))[9]))/60;' $FILE )


if  [ $FILEAGE -gt 360 ]                                                                                      
then
    echo "Loging into Vault"
    vault login -method=okta username=$USER |  egrep -oh "Success! You are now authenticated."
    echo " "
    STACK=$(echo $1 | cut -d . -f2 ) ; vault read cloud-sec-lve-ephemeral/creds/$STACK-admin/$1  | egrep 'username|password' | awk '{print $2}'
else
    STACK=$(echo $1 | cut -d . -f2 ) ; vault read cloud-sec-lve-ephemeral/creds/$STACK-admin/$1  | egrep 'username|password' | awk '{print $2}'
fi