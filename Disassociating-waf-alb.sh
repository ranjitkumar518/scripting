#!/bin/bash

echo "-------------------------------------------"
echo "##### Getting the Load balancer ARNs ######"
echo "-------------------------------------------"

while read -r line
do
	aws elbv2 describe-load-balancers --names $line --query "LoadBalancers[*].LoadBalancerArn" --output text >> arn_lbs.txt
done < public_lbs.txt

echo "-------------------------------------------"
echo "##### Disassociating the ALBs from WAF ######"
echo "-------------------------------------------"

while read -r line
do
	echo "Resource ARN-----> $line"
	aws waf-regional disassociate-web-acl --resource-arn $line
done < arn_lbs.txt
