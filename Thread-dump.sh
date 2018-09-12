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
