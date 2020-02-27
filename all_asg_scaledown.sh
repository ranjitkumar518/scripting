#!/bin/sh

#####################################################################################################################
###### script to decrease autoscaling group to 1 for desired only in preprod env ######
#####################################################################################################################


##### Get all availabale autoscaling groups
aws autoscaling describe-auto-scaling-groups   --output text  --query "AutoScalingGroups[*].{AutoScalingGroupName:AutoScalingGroupName,DesiredCapacity:DesiredCapacity}" >/tmp/autoscaling

while read line;
do
  desired=$(echo $line |awk '{print $2}')
  if [ $desired -ge 2 ];then
     scaling_grp_name=$(echo $line | awk '{print $1}')
     ##### Scale down the each auto scaling group desired capacity 1
     echo aws autoscaling update-auto-scaling-group --auto-scaling-group-name  $scaling_grp_name --min-size  1  --desired-capacity 1
     aws autoscaling update-auto-scaling-group --auto-scaling-group-name  $scaling_grp_name --min-size  1  --desired-capacity 1
  fi
done < /tmp/autoscaling
