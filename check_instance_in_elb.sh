#!/bin/bash

env=$1
region=$2

if [[ -z "$env" && "$env" = '' ]]
then
echo "env is missing"
echo "./check_instance_in_elb.sh <env> <region> "
exit -1;
fi

if [[ -z "$region" && "$region" = '' ]]
then
echo "region is missing"
echo "./check_instance_in_elb.sh <env> <region> "
exit -1;
fi

elblist="$component1 $component2 $component3 $component4 $component5 $$component6"

for i in $elblist
  do
    echo "$i elbstatus:"
    aws elb describe-instance-health --load-balancer-name $i-$env --query 'InstanceStates[*].{id:InstanceId,state:State}' --region $region --output table
  done
