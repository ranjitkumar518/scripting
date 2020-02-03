#!/bin/bash
region=$1
env=$2
status=$3
service=$4


if [ $# -ne 4 ]
  then
    echo "Invalid arguments. Example::: ./set_waf_alb_flag.sh us-west-2 prf true service_name "
    echo "Info::: service value must be webs_s1/webs_s2/webs_s3/webs_contingency/icp_services/eos"
    echo "Info: To enable pass true. To disable pass false"
fi

service_s1=(service-$env-s1 service-$env-s1 service-$env-s1)
service_s2=(service-$env-s2 service-$env-s2 service-$env-s2)

proceedfunc() {
   echo -n "Proceed? (y/n):"
   read PROCEEDASK

   until [ "${PROCEEDASK}" = "y" ] || [ "${PROCEEDASK}" = "n" ]; do
      echo -n "Please enter 'y' or 'n': "
      read PROCEEDASK
   done
}

service_s1() {
    for SERVICE in "${service_s1[@]}"; do
        echo "Updating the setting for $SERVICE ALB..."
        proceedfunc
        if [ "${PROCEEDASK}" = "y" ]; then
            echo "-------------------------------------------------------------------------------------------------------------------------------------\n"
            echo "Proceeding..."
            LoadBalancerArn=$(aws elbv2 describe-load-balancers --query 'LoadBalancers[*].LoadBalancerArn' --region $region --output json | grep $SERVICE | tr -d '",[,], ')
            echo "Updating waf.fail_open.enabled for $LoadBalancerArn"
            aws --region $region --profile default elbv2 modify-load-balancer-attributes  --load-balancer-arn $LoadBalancerArn --attributes Key=waf.fail_open.enabled,Value=$status |jq '.Attributes[] | "Key: "+.Key + " Value: "+ .Value' |grep waf.fail_open.enabled
            echo "Update completed...verifying now..."
            aws elbv2 describe-load-balancer-attributes --load-balancer-arn $LoadBalancerArn --profile default --region $region --output text |grep waf.fail_open.enabled
            echo "-------------------------------------------------------------------------------------------------------------------------------------\n\n"
        else
            echo "Skipping updation of setting for $SERVICE ALB"
        fi
    done
}

$4
