#!/bin/bash

# Get all the instance ip's in an account and store them in a file.
aws ec2 describe-instances  --query 'Reservations[*].Instances[*].{Id:InstanceId,Pri:PrivateIpAddress,State:State.Name}' --output table > /tmp/run_output.txt

# Filter the instance state (only running instances)
cat /tmp/run_output.txt |grep running | awk {'print $3'}  > /tmp/all_ips

# read each instance ip and run the commands that you want to run
while read ip;
do
  ssh $ip "stash --version" < /dev/null
  echo "IP:$ip" > /tmp/ssh_output;
done < /tmp/all_ips
