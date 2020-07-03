#!/bin/sh

### Fetch OK cloud watch alarms
aws cloudwatch describe-alarms --profile $1 --state-value OK   --output text --query "MetricAlarms[*].{AlarmName:AlarmName}" > /tmp/cloud_watch_alarm_ok
### Fetch INSUFFICIENT_DATA cloud watch alarms
aws cloudwatch describe-alarms --profile $1 --state-value INSUFFICIENT_DATA  --output text --query "MetricAlarms[*].{AlarmName:AlarmName}" > /tmp/cloud_watch_alarm_insuff_data
cat /dev/null > /tmp/all_alarms
cat /tmp/cloud_watch_alarm_ok  /tmp/cloud_watch_alarm_insuff_data | grep  Utliz | sort | uniq >/tmp/all_alarms

while read line;
do
     echo aws cloudwatch delete-alarms --alarm-names  $line
     aws cloudwatch delete-alarms --profile $1 --alarm-names  $line
done < /tmp/all_alarms
