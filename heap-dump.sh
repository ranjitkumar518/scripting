while true
do
  # /usr/local/java/bin/jmap -dump:format=b,file=filename.hprof $PID
  jmap -dump:file=/tmp/java-`date +%s`.hprof PID_OF_JVM
  # Sleep for 30 seconds and take the heap dump again.
  sleep 30
done
