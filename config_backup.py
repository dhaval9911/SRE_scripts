#!/bin/bash
 
SPLUNK_HOME=/opt/splunk
OUTPUT_DIR=/var/tmp/splunk_pstacks
SAMPLES=5
SAMPLE_PERIOD=1
mkdir -p $OUTPUT_DIR
i=0
while [ $i -lt $SAMPLES ]
do
    eu-stack -p `head -1 $SPLUNK_HOME/var/run/splunk/splunkd.pid` > $OUTPUT_DIR/pstack_splunkd-$i-`date +%s`.out
    i=$((i+1))
    sleep $SAMPLE_PERIOD
done
