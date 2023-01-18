cloudctl stacks get $1 > $1.yaml
sed -i '' '/maintenanceWindow/d' $1.yaml
sed -i '' '/ranges\:/d' $1.yaml
sed -i '' '/duration\:/d' $1.yaml
sed -i '' '/startTime\:/d' $1.yaml
sed -i '' '/repaver_allow_standalone\: true/d' $1.yaml
sed -i '' '/repaver_enabled\: true/d' $1.yaml
sed -i '' '/repaver_fast_mode\: true/d' $1.yaml 
sed -i '' '/repaver_schedule\: maintenance/d' $1.yaml
echo "https://splunk.atlassian.net/browse/$2"
echo "https://console.splunkcloud.systems/lve/stack/$1/proposal"
cloudctl stacks update $1 -f $1.yaml --reason "$2 Remove Repaver Flags"
rm $1.yaml

