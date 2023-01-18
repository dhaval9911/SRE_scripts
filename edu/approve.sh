read -p "Stackname: " stack

i = 1 

until [ $i -gt 9 ]
do
    cloudctl stacks approve $stack-0$i --version 1  --reason "GTG"
    ((i=i+1))
done


i = 10




until [ $i -gt 15 ]
do
    cloudctl stacks approve $stack-$i --version 1  --reason "GTG"
    ((i=i+1))
done

