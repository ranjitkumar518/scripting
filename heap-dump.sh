while true
do
  # /usr/local/java/bin/jmap -dump:format=b,file=filename.hprof $PID
  jmap -dump:file=/tmp/java-`date +%s`.hprof PID_OF_JVM
  sleep 30
done
