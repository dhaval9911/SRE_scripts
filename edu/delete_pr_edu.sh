read -p "Stackname: " stack
read -p "Version: " version
read -p "JIRA (TO- ) : " JIRA
i=1


until [ $i -gt 9 ]

do
    cloudctl stacks cancel $stack-0$i   --version $version  --reason "$JIRA cancel PR"
    ((i=i+1))
done


i=10

until [ $i -gt 15 ]

do
    cloudctl stacks cancel $stack-$i   --version $version --reason "$JIRA cancel PR"
    ((i=i+1))
done


cloudctl stacks cancel $stack-instructor --version $version   --reason "$JIRA cancel PR"


i=1

until [ $i -gt 9 ]

do 
   echo "https://web.co2.lve.splunkcloud.systems/stack/info/$stack-0$i/proposal"
   ((i=i+1))
done


i=10

until [ $i -gt 15 ]

do 
   echo "https://web.co2.lve.splunkcloud.systems/stack/info/$stack-$i/proposal"
   ((i=i+1))
done

   
echo " "
echo -------------------------------------------------------------------------------------------
echo " "   
echo "https://web.co2.lve.splunkcloud.systems/stack/info/$stack-instructor/proposal"
