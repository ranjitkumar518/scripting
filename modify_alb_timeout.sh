#!/bin/bash

ENV=$1
REGION=$2
SERVICE=$3
ALB_IDLE_TIMEOUT_VALUE=$4

usage () {
	echo "Usage: $0 {ENV} {REGION} {SERVICE} {ALB_IDLE_TIMEOUT_VALUE}"
	echo "Allowed values -"
	echo "      ENV: prf|e2e|prd"
	echo "      REGION: us-west-2|us-east-2"
  echo "      ALB_IDLE_TIMEOUT: 30|60"
  
  exit 1
}

## Verify the number of arguments passed to the script
[[ $# -ne 4 ]] && usage

## validate the alb timeout value passed to script
if [ "$ALB_IDLE_TIMEOUT_VALUE" != "60" ] && [ "$ALB_IDLE_TIMEOUT_VALUE" != "30" ] ; then
        echo "Please enter valid values for ALB Idle Timeout Value"
		usage
fi

## Set list of components variable 
set_list_components() {
    echo "-------------------------------------------------------------------------------------------------------------------------------------\n"
    echo "Setting component list based on input $SERVICE-$ENV..."
    echo "-------------------------------------------------------------------------------------------------------------------------------------\n\n"

    if [ "$SERVICE" == "webs" ]
    then
            COMPONENT_LIST=(webs-app1-$ENV webs-app2-$ENV webs-app1-$ENV)
    elif [ "$SERVICE" == "micro-service" ]
    then
            COMPONENT_LIST=(webs-appName1-$ENV webs-appName2-$ENV webs-appName3-$ENV)
    else
            echo "Invalid "
    fi
    echo "Set component list to [${COMPONENT_LIST[*]}]..."
}               
        
change_alb_timeout() {
    echo "-------------------------------------------------------------------------------------------------------------------------------------\n"
    echo "Starting ALB Idle Timeout change for $SERVICE in $REGION..."
    echo "-------------------------------------------------------------------------------------------------------------------------------------\n\n"

    for COMPONENT in "${COMPONENT_LIST[@]}"; do
            echo "Fetching ALB ARN for $COMPONENT..."
            LoadBalancerArn=$(aws --region $REGION elbv2 describe-load-balancers \
                --names $COMPONENT \
                --query 'LoadBalancers[*].LoadBalancerArn' --output text)
            echo "Updating idle timeout for $LoadBalancerArn"
            aws --region $REGION elbv2 modify-load-balancer-attributes  \
                --load-balancer-arn $LoadBalancerArn \
                --attributes Key=idle_timeout.timeout_seconds,Value=$ALB_IDLE_TIMEOUT_VALUE \
                |jq '.Attributes[] | "Key: "+.Key + " Value: "+ .Value' |grep idle_timeout.timeout_seconds

    done
}



verify_current_alb_timeout() {
    echo "-------------------------------------------------------------------------------------------------------------------------------------\n"
    echo "Verifying ALB Idle Timeout change for $SERVICE in $REGION..."
    echo "-------------------------------------------------------------------------------------------------------------------------------------\n\n"

    for COMPONENT in "${COMPONENT_LIST[@]}"; do
            echo "Fetching ALB ARN for $COMPONENT..."
            LoadBalancerArn=$(aws --region $REGION elbv2 describe-load-balancers \
                            --names $COMPONENT \
                            --query 'LoadBalancers[*].LoadBalancerArn' --output text)
            echo "Verifying idle timeout for $LoadBalancerArn"
            aws --region $REGION elbv2 describe-load-balancer-attributes \
                --load-balancer-arn $LoadBalancerArn --output text |grep idle_timeout.timeout_seconds
    done
}


##################### Main Execution ########################

set_list_components

change_alb_timeout

verify_current_alb_timeout

echo "-------------------------------------------------------------------------------------------------------------------------------------\n"
echo "Finished executing script for ALB Idle timeout $ALB_IDLE_TIMEOUT_VALUE in $SERVICE in $REGION..."
echo "-------------------------------------------------------------------------------------------------------------------------------------\n\n"

