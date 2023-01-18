



read -p "Stackname:- " stack
# read -p "Version:- " version
# user=student

# i=1
# until [ $i -gt 9 ]

# do
#     cloudctl stacks provision $stack-0$i --ref "TO-191044 EDU"    
#     #  open -a "Google Chrome" "https://web.co2.lve.splunkcloud.systems/lve/stack/$stack-0$i/status"
#     # PASSWORD=$(vault kv get -version=$version cloud-sec/std/lve/stacks/$stack-0$i/splunk_users/$user-$i/  | grep plaintext )
#     # echo $user-$i
#     # echo $PASSWORD  | sed 's/plaintext//g'   
#     # echo " "
#     echo "https://console.splunkcloud.systems/lve/stack/$stack-0$i/proposal"
#     ((i++))
# done

# i=10

# until [ $i -gt 15 ]

# do
#     cloudctl stacks provision $stack-$i --ref "TO-191044 EDU"    
#     #  open -a "Google Chrome" "https://web.co2.lve.splunkcloud.systems/lve/stack/$stack-$i/status"
#     # PASSWORD=$(vault kv get -version=$version cloud-sec/std/lve/stacks/$stack-$i/splunk_users/$user-$i/ | grep  plaintext )
#     # echo $user-$i
#     # echo $PASSWORD  | sed 's/plaintext//g' 
#     # echo " "
#     echo "https://console.splunkcloud.systems/lve/stack/$stack-$i/proposal"

#      ((i++))
# done

# cloudctl stacks provision $stack-instructor --ref "TO-191044 EDU"    

# -------------------------------------------------------------------------------------------------------------------------------------------------
i=1
until [ $i -gt 9 ]

do
    # cloudctl stacks provision $stack-0$i --ref "TO-191044 EDU"    
    #  open -a "Google Chrome" "https://web.co2.lve.splunkcloud.systems/lve/stack/$stack-0$i/status"
    # PASSWORD=$(vault kv get -version=$version cloud-sec/std/lve/stacks/$stack-0$i/splunk_users/$user-$i/  | grep plaintext )
    # echo $user-$i
    # echo $PASSWORD  | sed 's/plaintext//g'   
    # echo " "
    open -a "Google Chrome" "https://console.splunkcloud.systems/lve/stack/$stack-0$i/proposal"
    ((i++))
done

i=10

until [ $i -gt 15 ]

do
    # cloudctl stacks provision $stack-$i --ref "TO-191044 EDU"    
    #  open -a "Google Chrome" "https://web.co2.lve.splunkcloud.systems/lve/stack/$stack-$i/status"
    # PASSWORD=$(vault kv get -version=$version cloud-sec/std/lve/stacks/$stack-$i/splunk_users/$user-$i/ | grep  plaintext )
    # echo $user-$i
    # echo $PASSWORD  | sed 's/plaintext//g' 
    # echo " "
    open -a "Google Chrome" "https://console.splunkcloud.systems/lve/stack/$stack-$i/proposal"

     ((i++))
done




    echo "https://console.splunkcloud.systems/lve/stack/$stack-instructor/proposal"
#  open -a "Google Chrome" "https://web.co2.lve.splunkcloud.systems/lve/stack/$stack-instructor/status"
