#!/bin/bash
cd $1
nohup ./jetty.sh > out.log 2>&1 &
echo "..............."
sleep 100
PID_COUNT=$(ps -ef | grep jetty | grep -v grep | grep -v "ansible" | wc -l)
echo $PID_COUNT
# if Process started
if [ $PID_COUNT -eq 0 ]
then 
  echo "Jetty Server not started"
elif [ $PID_COUNT -ge 1 ] 
then    
    echo “Server process found...will wait for sometime” 
    sleep 100
    echo "Scanning logs"
    # if started with errors,exit status 1 is returned
    if grep -wi "started (with errors)" out.log > /dev/null
    then
      echo “Started with Errors” 
      #       verifyDeploymentStatus $JBOSS_HOME $1 $2             
    # if clean start, exit status 0 is returned
    elif grep -wi "started in" out.log > /dev/null
    then 
      echo "Started"    
    #  verifyDeploymentStatus $JBOSS_HOME $1 $2
    else
        echo "Failed"
      echo “Failed to Start Server”
  fi  
# if Process does not succeed, exit status 2,means Failed   
else 
  echo “Failed to execute CLI Start command”  
fi

