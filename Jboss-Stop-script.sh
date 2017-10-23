#setting variables 
JBOSS_HOME=$4

# clearLogAndTempFiles - Stop Server and delete log and temp contents
#Input Parameters $1 - Port , $2 - Jboss server instance name 
function clearLogAndTempFiles() {
	echo "Removing logs and tmp directories..."
    echo "Removing logs and tmp directories..." >> "$JBOSS_HOME/standalone/log/Weekend_maintenance.log"
	cd $JBOSS_HOME/standalone/log
	#cp server.log ../server.log_TS
	#rm *.log *.log*
	find . -type f ! -name 'Restart_*' -delete
    #cp ../server.log_TS .
	echo "Removed log files..."
    echo "Removed log files..." >> "$JBOSS_HOME/standalone/log/Weekend_maintenance.log"
	cd $JBOSS_HOME/standalone/tmp/vfs/
	rm -rf deployment* temp*
	echo ""
	echo "Removed log temp files..."
    echo "Removed temp files..." >> "$JBOSS_HOME/standalone/log/Weekend_maintenance.log"
}

# Main - Stop Server and Remove log,temp contents
#Input Parameters $1 - Port , $2 - Host IP, $3 - serverInstanceName, $4 - JBOSS_HOME
PRE_STOP_PID_COUNT=$(ps -ef | grep $3 | grep jboss.server.base | grep -v grep | grep -v "ansible" | wc -l)
if [ $PRE_STOP_PID_COUNT -eq 0 ]
then
    echo "Server $3 is already down..."
    echo "Server $3 is already down..." >> "$JBOSS_HOME/standalone/log/Weekend_maintenance.log"
    exit 0
fi    

cd $JBOSS_HOME/bin
echo "Stoping server $2:$1" >> "$JBOSS_HOME/standalone/log/Weekend_maintenance.log"
CLI_COMMAND="jboss-cli.sh --connect --controller=$2:$1 --command=:shutdown"
#CLI_COMMAND="jboss-cli.sh --connect --command=:shutdown"
output=`./$CLI_COMMAND`
CLI_OUTCOME=$(echo $output | grep '{"outcome" => "success"}' | wc -l)
# if CLI command succeeds
if [ $CLI_OUTCOME -eq 1 ]
then
    echo "Server $3 is being stopped..."
    echo "Server $3 is being stopped..." >> "$JBOSS_HOME/standalone/log/Weekend_maintenance.log"
    sleep 40
    # poll for PID. if PID exists, exit status 1 is returned, means it is still running
   	for (( y=0; y<5; y++ ))
	do
     	PID_COUNT=$(ps -ef | grep $3 | grep jboss.server.base | grep -v grep | grep -v "ansible" | wc -l)
    	echo $PID_COUNT
    	if [ $PID_COUNT -eq 0 ]
        then
             echo "process $3 stopped"
             echo "process $3 stopped" >> "$JBOSS_HOME/standalone/log/Weekend_maintenance.log"
    	     break
        else 
             echo "process $3 still running"
             echo "process $3 still running..." >> "$JBOSS_HOME/standalone/log/Weekend_maintenance.log"
             sleep 20
    	fi    	
	done
    #Force kill the process if it is not getting stopped
	PID_COUNT=$(ps -ef | grep $3 | grep jboss.server.base | grep -v grep | grep -v "ansible" | wc -l)        
    if [ $PID_COUNT -eq 1 ]
    then
		process_id=$(ps aux | grep -v grep | grep -v "ansible" | grep jboss.server.base | grep $3 | awk '{ print $2 }')
		echo "Server Not Stoping… Doing Force Kill $process_id " >> "$JBOSS_HOME/standalone/log/Weekend_maintenance.log"
		echo $process_id
		kill -9 $process_id
        echo "Failed to Stop Server" >> "$JBOSS_HOME/standalone/log/Weekend_maintenance.log"
        ./NotifyMail.sh ER002 $3 $2 $1
	fi
    # if PID does not exist, exit status 0 is returned, means Stopped, hence clearing the temp and log files
	if [ $PID_COUNT -eq 0 ]
    then
    	clearLogAndTempFiles $1 $3    	
    fi     
# if CLI command does not succeed, exit status 2,means Failed   
else
    echo "Failed to execute CLI Stop command" >> "$JBOSS_HOME/standalone/log/Weekend_maintenance.log"
    process_id=$(ps aux | grep -v grep | grep -v "ansible" | grep jboss.server.base | grep $3 | awk '{ print $2 }')
     echo "Killed process $process_id " >> "$JBOSS_HOME/standalone/log/Weekend_maintenance.log"
    echo $process_id
    kill -9 $process_id
    clearLogAndTempFiles $1 $3    
fi

