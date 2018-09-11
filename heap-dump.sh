#!/bin/bash
PID=$1
while true
do
  # /usr/local/java/bin/jmap -dump:format=b,file=filename.hprof $PID
  jmap -dump:file=/tmp/java-`date +%s`.hprof $1
  # Sleep for 30 seconds and take the heap dump again.
  sleep 30
done
