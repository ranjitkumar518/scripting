# notifyMail - Sends email notification
#Parameter $1 for Error code
#Parameter $2 for Server Instance name
#Parameter $3 for Host IP
#Parameter $4 is port
#Parameter $5 is Mail Subject
#Parameter $6 is Mail Body
function notifyMail() {
	LOG_PATH=$JBOSS_HOME/standalone/log/"Restart_Email_Log".txt
	HOST_NAME=`hostname`
	MessageHeader="$5"
	Message="$6"
	TO_ADDRESS='mailid@domain.com'
	FROM_ADDRESS='team_mailid@domain.com'
	echo "From: ${FROM_ADDRESS}" >$LOG_PATH
	echo "To: ${TO_ADDRESS}" >>$LOG_PATH
	echo "Subject:${MessageHeader} $HOST_NAME ($3)">>$LOG_PATH
	echo "Content-Type: text/html; charset=\"us-ascii\"" >> $LOG_PATH
	echo "<table width=100% align=center border=2 align=center cellpadding=2 cellspacing=2><tbody ><tr style=background-color:#9C9C9C><td width=50% >HOST NAME : $HOST_NAME ($3)  </td> </tr> <tr style=background-color:#9C9C9C> <td  width=50%>  SERVER NAME:  $2  </td> </tr> "  >> $LOG_PATH
	echo "<tr> <td > ${Message} </td> </tr> " >>$LOG_PATH
	echo " <tr > <td > Please find the list of the Applications Failed to deploy </td > </tr>  " >>$LOG_PATH 
	cd $JBOSS_HOME/bin
	./jboss-cli.sh -c --controller=$3:$4 --command=deployment-info > $DEPLOY_LOG_TEMP
	loop=2
	count=`cat $DEPLOY_LOG_TEMP | wc -l`
	failcount=0
	while [ $loop -le $count ]
	do
		value=`cat $DEPLOY_LOG_TEMP| awk NR==$loop `
		filename=`echo $value | awk '{ print $1 }'`
		status=`echo $value | awk '{ print $5 }'`
		loop=`expr $loop + 1`	
		if [ -n "$status" ] &&  [ "$status" != "OK" ]
  		then
            failcount=`expr $failcount + 1`   	
			echo " <tr > <td >$filename   </td> </tr>   " >>$LOG_PATH                 	
		fi
	done	
	echo " </tbody></table> " >>$LOG_PATH
	cd $org_path
	if [ "$1" == "SA001" ]	 &&  [ $failcount -eq 0 ]
	then
		rm $DEPLOY_LOG_TEMP 
		rm $LOG_PATH > /dev/null
	else
	    #Calling send mail utility
	    /usr/sbin/sendmail -t < $LOG_PATH
	fi
	echo "Notification Sent!!!"
}	

# startNotifications - sends out notifications related to startup
#Parameter $1 for Server Instance name
#Parameter $2 for Host IP
#Parameter $3 is port
function startNotifications() {
	echo "Checking if any startup notifications need to be sent..."
	# Determining error code and associated details
	PID_COUNT=$(ps -ef | grep $1 | grep jboss.server.base | grep -v grep | grep -v "ansible" | wc -l)
	echo $PID_COUNT
	# if Process started
	if [ $PID_COUNT -eq 0 ]
	then 
	  echo "Server down."
	  notifyMail ER004 $1 $2 $3 "$ER004_HEADER" "$ER004_MESSAGE"
	elif [ $PID_COUNT -eq 1 ] 
	then	
	  echo "Server process found...Scanning logs"
	  # if started with errors,exit status 1 is returned
	  if grep "started (with errors)" $JBOSS_HOME/bin/out.log > /dev/null
	  then
		echo "Started with Errors"
	    notifyMail ER003 $1 $2 $3 "$ER003_HEADER" "$ER003_MESSAGE"	
	  # if clean start, exit status 0 is returned 
	  elif grep "started in" $JBOSS_HOME/bin/out.log > /dev/null
	  then 
	    echo "Started"
	  	notifyMail SA001 $1 $2 $3 "$SA001_HEADER" "$SA001_MESSAGE"  	
	  else
	    echo "Failed"
	    notifyMail ER004 $1 $2 $3 "$ER004_HEADER" "$ER004_MESSAGE"  
	  fi  
	else 
	  echo "Failed"
	  notifyMail ER004 $1 $2 $3 "$ER004_HEADER" "$ER004_MESSAGE"  
	fi
}

# startNotifications - sends out notifications related to shutdown
#Parameter $1 for Server Instance name
#Parameter $2 for Host IP
#Parameter $3 is port
function shutdownNotifications() {
	#check if server is not getting stopped
	echo "Checking if any shutdown notifications need to be sent..."
	PID_COUNT=$(ps -ef | grep $1 | grep jboss.server.base | grep -v grep | grep -v "ansible" | wc -l) 
	if [ $PID_COUNT -eq 1 ]
    then
    	echo "Failed to Stop Server"
    	notifyMail ER002 $1 $2 $3 "$ER002_HEADER" "$ER004_MESSAGE" 
    fi	
}

# Main - Notifications
#Parameter $1 for Server Instance name
#Parameter $2 for Host IP
#Parameter $3 is port
#Parameter $4 is JBOSS_HOME
#Parameter $5 is function
JBOSS_HOME=$4
DEPLOY_LOG_TEMP=$JBOSS_HOME/standalone/log/"Restart_Deploystatus_Temp".txt

# Standard Error-based headers/contents to include in the email
ER001_HEADER='Weekly Maintenance -Failed to execute CLI Command - Stop Server at Host.' 
ER001_MESSAGE='Please verify the mentioned server instance. Couldn’t able to to execute CLI Command - Stop the Server.'
ER002_HEADER='Weekly Maintenance -Failed to Stop Server at Host.'
ER002_MESSAGE='Please verify the mentioned server instance. Couldn’t able to Stop the Server.'
ER003_HEADER='Weekly Maintenance -Server Started with Errors at Host.'
ER003_MESSAGE='Please verify the mentioned server instance. Server Started with Errors.'
ER004_HEADER='Weekly Maintenance -Failed to Start Server at Host.' 
ER004_MESSAGE='Please verify the mentioned server instance. Couldn’t able to Start the Server.'
ER005_HEADER='Weekly Maintenance -Failed to execute CLI Command - Start Server at Host.' 
ER005_MESSAGE='Please verify the mentioned server instance. Couldn’t able to to execute CLI Command - Start the Server.'
SA001_HEADER='Server Started but some Applications Failed to deploy.' 
SA001_MESSAGE='Server Started but some Applications Failed to deploy.'

$5 $1 $2 $3

