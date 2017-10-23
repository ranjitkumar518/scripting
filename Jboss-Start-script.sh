#invoking the profile file to export env_variables
JBOSS_HOME=$4
JSF_APP_LIST=(domo.war.dodeploy gbicdn.war.dodeploy UploadFile.war.dodeploy File.war.dodeploy OnDemand.war.dodeploy ScheduleReport.war.dodeploy SBSOnDemand.war.dodeploy SalesByStateScheduledReport.war.dodeploy PX4UserHistory.war.dodeploy OmnitureDashboard.war.dodeploy ProductCostSecurity.war.dodeploy ECostUI.war.dodeploy URF.war.dodeploy USEDUReportingUI.war.dodeploy ALACReportingUI.war.dodeploy FinRefPortalReport.war.dodeploy)
DEPLOY_LOG=$JBOSS_HOME/standalone/log/"Restart_DeploymentStatus".txt

# verifyDeploymentStatus - Verify  Deployment Status and touch War in case of JSF applications 
#Input Parameters $1 - Jboss home path
verifyDeploymentStatus() {
    org_path=$PWD  
    echo $org_path
    cd $1/standalone/deployments/
    #Touching JSF Related War files
    for (( j=0; j<${#JSF_APP_LIST[@]}; j++ ))
  	do
      echo “Touching JSF Application ${JSF_APP_LIST[$i]}” >> "$JBOSS_HOME/standalone/log/Restart_maintenance.log"
		  # Check if the JSF applications are deployed in the current instance. If yes, touch it.
      if [ -f "${JSF_APP_LIST[$i]}" ] 
      then
        touch ${JSF_APP_LIST[$i]}
        sleep 100
      fi  
    done
    echo “Verifying Deployment Status” >> "$JBOSS_HOME/standalone/log/Restart_maintenance.log"
	  for (( z=0; z<5; z++ ))
    do
      echo $1/standalone/deployments/
		  deploying_count=$(find $1/standalone/deployments/ -name *.isdeploying | wc -l)
 		  failed_count=$(find $1/standalone/deployments/ -name *.failed | wc -l)
		  if [ $deploying_count -gt 0 ] 
      then
          echo “Still deployment is going on….” >> "$JBOSS_HOME/standalone/log/Restart_maintenance.log"
      elif [ $failed_count -gt 0 ]
      then
          echo “Few deployment failed , see the list” >> "$JBOSS_HOME/standalone/log/Restart_maintenance.log"
          break
      else
          echo “Deployment success” >> "$JBOSS_HOME/standalone/log/Restart_maintenance.log"
          break
      fi
      sleep 30
    done
    cd $1/bin/        
    ./jboss-cli.sh -c --controller=$3:$2 --command=deployment-info > $DEPLOY_LOG
  	loop=2
  	count=`cat $DEPLOY_LOG | wc -l`
  	while [ $loop -le $count ]
	  do
  		value=`cat $DEPLOY_LOG | awk NR==$loop `
  		filename=`echo $value | awk '{ print $1 }'`
  		status=`echo $value | awk '{ print $5 }'`
  		echo $filename $status >> "$JBOSS_HOME/standalone/log/Restart_maintenance.log"
  		echo $filename $status
  		loop=`expr $loop + 1`	
  		if [ -n "$status" ] &&  [ "$status" != "OK" ]
    	then
       		cd $1/standalone/deployments/
          echo “Touching file $filename ” >> "$JBOSS_HOME/standalone/log/Restart_maintenance.log"
  			  touch $filename
          sleep 100
  		fi
	  done	
    cd $org_path
    echo “File List under deployment folder — ” >> "$JBOSS_HOME/standalone/log/Restart_maintenance.log"
   	echo $(find $1/standalone/deployments/ -name \*.war.* -type f -exec basename {} \;) >> "$JBOSS_HOME/standalone/log/Restart_maintenance.log"        
}

#Main - Start Server and Verify deployment status
#Input Parameters $1 - Port number , $2 - Host IP , $3 servername, $4 - JBOSS_HOME
echo "Starting $3 server"
echo “Starting $3 server” >> "$JBOSS_HOME/standalone/log/Restart_maintenance.log"
cd $JBOSS_HOME/bin
var_path=$PWD  
echo $var_path
nohup ./standalone.sh --server-config=standalone-ha.xml -b $2 -Djboss.bind.address.management=$2 -Djgroups.bind_addr=$2  > out.log 2>&1 &
#./standalone.sh > out.log 2>&1 &
echo "......"
sleep 100
echo $3
PID_COUNT=$(ps -ef | grep $3 | grep jboss.server.base | grep -v grep | grep -v "ansible" | wc -l)
echo $PID_COUNT
# if Process started
if [ $PID_COUNT -eq 0 ]
then 
  echo "process not started"
elif [ $PID_COUNT -eq 1 ] #change gt to eq
then	
	echo "Server process found...will wait for sometime"
  echo “Server process found...will wait for sometime” >> "$JBOSS_HOME/standalone/log/Restart_maintenance.log"
	sleep 100
	echo "Scanning logs"
	# if started with errors,exit status 1 is returned
	if grep "started (with errors)" out.log > /dev/null
	then
 			echo "Started with Errors"
      echo “Started with Errors” >> "$JBOSS_HOME/standalone/log/Restart_maintenance.log"
 			verifyDeploymentStatus $JBOSS_HOME $1 $2 			
	# if clean start, exit status 0 is returned
	elif grep "started in" out.log > /dev/null
	then 
      echo "Started"	
      verifyDeploymentStatus $JBOSS_HOME $1 $2
	else
	    echo "Failed"
      echo “Failed to Start Server” >> "$JBOSS_HOME/standalone/log/Restart_maintenance.log"
  fi  
# if Process does not succeed, exit status 2,means Failed   
else 
	echo "Failed"
  echo “Failed to execute CLI Start command” >> "$JBOSS_HOME/standalone/log/Restart_maintenance.log"	
fi

