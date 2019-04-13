#!/usr/bin/env bash

if [ $# -lt 3 ]; then
      echo "Usage: ./check_elb_instance_health.sh <ENV> <AWS_PROFILE> <COMPONENT>"
      echo "Required: ENV, AWS_PROFILE, COMPONENT"
      echo "Example: ./check_elb_instance_health.sh prf2 preprod web-app"
      echo "Example: ./check_elb_instance_health.sh prf2-green preprod web-app"
      exit
fi

ENV=$1
AWS_PROFILE=$2
COMPONENT=$3

## ELB name is combination of Component and environment. EXample: $COMPONENT-$ENV
echo --- Healthy instances to the ELB $COMPONENT-$ENV ---

aws elb describe-instance-health --profile $AWS_PROFILE \
    --load-balancer-name $COMPONENT-$ENV \
    --query 'InstanceStates[?State==`InService`].[InstanceId,State]' \
    --output table

echo --- Unhealthy instances to the ELB $COMPONENT-$ENV ---
aws elb describe-instance-health --profile $AWS_PROFILE \
    --load-balancer-name $COMPONENT-$ENV \
    --query 'InstanceStates[?State!=`InService`].[InstanceId,State]' \
    --output table
