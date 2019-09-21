#!/bin/bash

env=$1
region=$2

elblist="$component1 $component2 $component3 $component4 $component5 $$component6"

for i in $elblist
  do
    echo "$i elbstatus:"
    aws elb describe-instance-health --load-balancer-name $i-$env --query 'InstanceStates[*].{id:InstanceId,state:State}' --region $region --output table
  done
