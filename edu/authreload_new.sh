#need to do vault login to get password
#need to do sft ssh on any node (for browser approve)

#!/bin/sh
echo "#example : class id:edu13000    class size:15\n"
read -p "class id: " class_id
read -p "class size: " class_size

# for instructor sh and idm

instructor_stack=$(nslookup sh1.$class_id-instructor.splunkcloud.com | awk '{print $1}' | grep ".-i-" | awk -F. '{print $2}')
PASS=$(vault kv get cloud-sec/std/lve/stacks/$instructor_stack/admin | grep plaintext | awk {'print $2'});
instructor_sh_fqdn=$(nslookup sh1.$class_id-instructor.splunkcloud.com | awk '{print $1}' | grep ".-i-" | awk -F. '{print $1}')
ssh -tt splunk@$instructor_sh_fqdn << EOF
    sudo puppet agent -t
    sudo su - splunk
    splunk reload auth -auth 'admin:$PASS'
    exit
    exit
EOF
instructor_idm_fqdn=$(nslookup idm1.$class_id-instructor.splunkcloud.com | awk '{print $1}' | grep ".-i-"  | awk -F. '{print $1}')
ssh -tt splunk@$instructor_idm_fqdn << EOF
    sudo puppet agent -t
    sudo su - splunk
    splunk reload auth -auth 'admin:$PASS'
    exit
    exit
EOF

# for class size sh and idm 

for i in $(seq 1 $class_size)
do 
    xpad=$(printf '%02d' $i)
    STACK_NAME=$(nslookup sh1.$class_id-$xpad.splunkcloud.com | awk '{print $1}' | grep ".-i-" | awk -F. '{print $2}')
    PASS=$(vault kv get cloud-sec/std/lve/stacks/$STACK_NAME/admin | grep plaintext | awk {'print $2'});

    SH1=$(nslookup sh1.$class_id-$xpad.splunkcloud.com | awk '{print $1}' | grep ".-i-"  | awk -F. '{print $1}')
    ssh -tt splunk@$SH1 << EOF
    sudo puppet agent -t
    sudo su - splunk
    splunk reload auth -auth 'admin:$PASS'
    exit
    exit
EOF
    IDM1=$(nslookup idm1.$class_id-$xpad.splunkcloud.com | awk '{print $1}' | grep ".-i-"  | awk -F. '{print $1}')
    ssh -tt splunk@$IDM1 << EOF
    sudo puppet agent -t
    sudo su - splunk
    splunk reload auth -auth 'admin:$PASS'
    exit
    exit
EOF
done
