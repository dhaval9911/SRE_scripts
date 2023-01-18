#!/bin/bash

CURRENT=$(cloudctl stacks get $1  | egrep "^version\:" | sed 's/^version\: //g')

PR=$(expr $CURRENT + 1)

cloudctl stacks diff  $1 $CURRENT $PR


if $? | grep -q 'endVersion';
then
   echo "Version $PR not found" ;
   exit ;
fi

while true; do
    read -p "Approve MR? " yn
    case $yn in
        [Yy]* ) cloudctl stacks approve $1 $PR ; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done




# cloudctl stacks approve $1 $PR ; break;;