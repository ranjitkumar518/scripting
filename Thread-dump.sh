#!/bin/bash
# $1 is the PID of the JVM. Please pass the the PID to this script
while true
do
  # /usr/java/jdk1.8.0_131/bin/jstack is the Jstack Home directory
  jstack -l $1 > stack-`date +%s`.txt
  ## run command 5 times  
  ## for i in {1..5}; do /usr/java/jdk1.8.0_131/bin/jstack -l $1 > stack-`date +%s`.txt ; done
  # Sleep for 30 seconds to execute the same script
  sleep 30
done

# Command to take Thread dump for every 10 seconds.
#CLUSTER_NAME=$(hostname|grep -o -E c[0-9]{2});echo ${CLUSTER_NAME};COUNTER=0 ; mkdir -p ${CLUSTER_NAME};while true; do sleep 10; ((COUNTER++));echo "Taking thread dump..." ${COUNTER}; /usr/java/jdk1.8.0_131/bin/jstack -l $pid >  ${CLUSTER_NAME}/dumps_$(date "+%F%T"|sed 's/://g') ;if [ ${COUNTER} -eq 5 ]; then  tar -cvzf  ${CLUSTER_NAME}.tar ${CLUSTER_NAME}; fi; done
