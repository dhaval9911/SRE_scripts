FILENAME="stacks"
LINES=$(cat $FILENAME)
for LINE in $LINES
do
	echo StackName: $LINE
	cloudctl stacks get $LINE | egrep '^\s account:|^\s region:|404|Un|no stack'
	echo "\n"
done
