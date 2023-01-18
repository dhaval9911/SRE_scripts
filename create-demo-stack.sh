read -p "Stackname: " stack
read -p "Jira ticket (Example: TO-16301): "  JIRA 


i=1

until [ $i -gt 9 ]

do 
   cloudctl stacks create $stack$i -f demo.yaml --reason "TO-$JIRA Build Stack"
   ((i=i+1))
done


i=10

until [ $i -gt 15 ]

do 
   cloudctl stacks create $stack$i -f demo.yaml --reason "TO-$JIRA Build Stack"
   ((i=i+1))
done


