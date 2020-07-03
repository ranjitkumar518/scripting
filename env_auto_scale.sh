#! /bin/sh 


getAutoscalingname(){
    aws autoscaling describe-auto-scaling-groups --query "AutoScalingGroups[?contains(Tags[?Key=='Cfn-Create-Action'].Value, 'Active')].[AutoScalingGroupName]" | grep "$1" | tr -d '",[,], '
}

scalingType=$1
autoscaleEnv=$2
awsRegion=$3

if [ $# -ne 3 ]
  then
  
    echo "In-correct Arguments supplied."
    echo "usage: sh icp_autoscale.sh scale-up prf us-west-2"
    echo "usage: sh icp_autoscale.sh scale-down prf us-west-2"
    scalingType=novaluepassed
fi

export AWS_DEFAULT_REGION=$awsRegion
export AWS_DEFAULT_OUTPUT=text

appName=(appName1  appName2 appName3 appName4 appName5)
# Autoscale min/desired Values used for scale up 
scaleUpmin=(3 3 3 3 6)
scaleUpmax=(6 6 6 6 12)

# Autoscale Down Value 
scaleDownmin=(1 1 1 1 1)
scaleDownmax=(3 3 3 3 3)


len=${#appName[@]}

case $scalingType in 
    "scale-up")
        for ((i=0; i<$len; i++))
        do
            autoscalingname=$(getAutoscalingname ${autoscaleEnv}-.*${appName[$i]})

            for scalename in $autoscalingname
            do
                    echo "Autoscaling Name $scalename"
                    aws autoscaling update-auto-scaling-group --auto-scaling-group-name $scalename --min-size ${scaleUpmin[$i]}  --max-size ${scaleUpmax[$i]} --desired-capacity ${scaleUpmin[$i]}
                    echo "Auto Scaled Up to Max :${scaleUpmax[$i]} $ & Desired Capacity :${scaleUpmin[$i]}"

            done
        done 
        ;;

     "scale-down")
        for ((i=0; i<$len; i++))
        do
            autoscalingname=$(getAutoscalingname ${autoscaleEnv}-.*${appName[$i]})
            for scalename in $autoscalingname
            do
                    echo "Autoscaling Name $scalename"
                    aws autoscaling update-auto-scaling-group --auto-scaling-group-name $scalename --min-size ${scaleDownmin[$i]}  --max-size ${scaleDownmax[$i]} --desired-capacity ${scaleDownmin[$i]}
                    echo "Auto Scaled Up to Max :${scaleDownmax[$i]} $ & Desired Capacity :${scaleDownmin[$i]}"

            done
        done 
        ;;
    
    *)  
        echo "Please pass the correct parameter"
        echo "---------------------------------"
        echo "Usage: $0 { scale-up autoscaleing-name env region  | scale-down autoscaleing-name env region }"
        echo " To Scale up  : $0 scale-up prf us-west-2"
        echo " To Scale Down : $0 scale-down prf us-west-2" 
        ;;
esac
