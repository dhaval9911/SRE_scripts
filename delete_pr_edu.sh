read -p "Stackname: " stack
read -p "JIRA (TO- ) : " JIRA
i=1


until [ $i -gt 9 ]

do
    cloudctl stacks cancel $stack-0$i   --version 1  --reason "$JIRA cancel PR"
    ((i=i+1))
done


i=10

until [ $i -gt 15 ]

do
    cloudctl stacks cancel $stack-$i   --version 1 --reason "$JIRA cancel PR"
    ((i=i+1))
done


cloudctl stacks cancel $stack-instructor --version 1   --reason "$JIRA cancel PR"


i=1

until [ $i -gt 9 ]

do 
   echo "https://web.co2.lve.splunkcloud.systems/stack/info/$stack-0$i/proposals"
   ((i=i+1))
done


i=10

until [ $i -gt 15 ]

do 
   echo "https://web.co2.lve.splunkcloud.systems/stack/info/$stack-$i/proposals"
   ((i=i+1))
done

   
echo " "
echo -------------------------------------------------------------------------------------------
echo " "   
echo "https://web.co2.lve.splunkcloud.systems/stack/info/$stack-instructor/proposals"
