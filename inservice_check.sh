#!/bin/bash

env=$1
region=$2

elblist="app1 app2 app3 app4"

# Validate the instances are healthy or not under the ELB/ALB
for i in $elblist
  do
    echo "$i elbstatus:"
    aws elb describe-instance-health --load-balancer-name $i-$env --query 'InstanceStates[*].{id:InstanceId,state:State}' --region $region --output table
  done
