read -p "Stackname: " stack
read -p "JIRA (TO- ) : " JIRA
i=1


until [ $i -gt 9 ]

do
    cloudctl stacks delete $stack-0$i  --reason "$JIRA First Step Termination"
    ((i=i+1))
done


i=10

until [ $i -gt 15 ]

do
    cloudctl stacks delete $stack-$i   --reason "$JIRA First Step Termination"
    ((i=i+1))
done


cloudctl stacks delete $stack-instructor --reason "$JIRA First Step Termination"


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
