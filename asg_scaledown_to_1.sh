#!/bin/sh

#######################################
# script to Scaledown all autoscaling group to 1 for desired. 
#
# Recommened to run only in preprod environment
#######################################

####### Get all ASG's with desired instances in any AWS account ########

aws autoscaling describe-auto-scaling-groups   --output text  --query "AutoScalingGroups[*].{AutoScalingGroupName:AutoScalingGroupName,DesiredCapacity:DesiredCapacity}" >/tmp/autoscaling

#### Read each line from /tmp/autoscaling and execute the scaledown cli command
while read line;
do
  desired=$(echo $line |awk '{print $2}')
  if [ $desired -ge 2 ];then
     scaling_grp_name=$(echo $line | awk '{print $1}')
     echo aws autoscaling update-auto-scaling-group --auto-scaling-group-name  $scaling_grp_name --min-size  1  --desired-capacity 1
     aws autoscaling update-auto-scaling-group --auto-scaling-group-name  $scaling_grp_name --min-size  1  --desired-capacity 1
  fi
done < /tmp/autoscaling
