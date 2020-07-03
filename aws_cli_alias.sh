[toplevel]

instance =
  !f() {
  	aws ec2 describe-instances --output table --filters Name=instance-id,Values=$1 --query "Reservations[*].Instances[*].{ Instance:InstanceId,ID: InstanceId,Instance:ImageId,Type:InstanceType,AZ:Placement.AvailabilityZone,Name:Tags[?Key==\`Name\`]|[0].Value,IP:PrivateIpAddress,State:State.Name}"
  }; f

healthcheck =
  !f() {
    icp_env=$1
    region=$2

    tgList=`aws --region $region elbv2 describe-target-groups --query 'TargetGroups[*].[TargetGroupArn]' --output text | grep -w "$icp_env" | grep -v 'contg\|green'`

    for tg in $tgList; do
        echo "TargetGroup $tg Instance Health Status:"
        aws --region $region elbv2 describe-target-health --target-group-arn $tg --query 'TargetHealthDescriptions[*].{id:Target.Id,state:TargetHealth.State}' --output table
    done
  }; f

scaledown =
   !f() {
     if [ $2 = "Active" ]; then
        asg_name=`aws autoscaling describe-auto-scaling-groups --query "AutoScalingGroups[?contains(Tags[?Key=='Cfn-Create-Action'].Value, 'Active')].[AutoScalingGroupName]" | grep $1 | tr -d '"'`
     else
        asg_name=`aws autoscaling describe-auto-scaling-groups --query "AutoScalingGroups[?contains(Tags[?Key=='Cfn-Create-Action'].Value, 'Ready')].[AutoScalingGroupName]" | grep $1 | tr -d '"'`
     fi

     for asg in $asg_name;
       do
        echo "Scaling Down $asg"
	aws --region us-west-2 autoscaling update-auto-scaling-group --auto-scaling-group-name $asg --min-size ${3} --max-size ${3} --desired-capacity ${3}
       done
   }; f

whoami = sts get-caller-identity

create-assume-role =
  !f() {
    aws iam create-role --role-name "${1}" \
      --assume-role-policy-document \
        "{\"Statement\":[{\
            \"Action\":\"sts:AssumeRole\",\
            \"Effect\":\"Allow\",\
            \"Principal\":{\"Service\":\""${2}".amazonaws.com\"},\
            \"Sid\":\"\"\
          }],\
          \"Version\":\"2012-10-17\"\
        }";
  }; f


running-instances = ec2 describe-instances \
    --filter Name=instance-state-name,Values=running \
    --output table \
    --query 'Reservations[].Instances[].{ID: InstanceId,Hostname: PublicDnsName,Name: Tags[?Key==`Name`].Value | [0],Type: InstanceType, Platform: Platform || `Linux`}'

ebs-volumes= ec2 describe-volumes \
    --query 'Volumes[].{VolumeId: VolumeId,State: State,Size: Size,Name: Tags[0].Value,AZ: AvailabilityZone}' \
    --output table

amazon-linux-amis = ec2 describe-images \
    --filter \
      Name=owner-alias,Values=amazon \
      Name=name,Values="amzn-ami-hvm-*" \
      Name=architecture,Values=x86_64 \
      Name=virtualization-type,Values=hvm \
      Name=root-device-type,Values=ebs \
      Name=block-device-mapping.volume-type,Values=gp2 \
    --query "reverse(sort_by(Images, &CreationDate))[*].[ImageId,Name,Description]" \
    --output text

list-sgs = ec2 describe-security-groups --query "SecurityGroups[].[GroupId, GroupName]" --output text

sg-rules = !f() { aws ec2 describe-security-groups \
    --query "SecurityGroups[].IpPermissions[].[FromPort,ToPort,IpProtocol,join(',',IpRanges[].CidrIp)]" \
    --group-id "$1" --output text; }; f

tostring =
  !f() {
    jp -f "${1}" 'to_string(@)'
  }; f

tostring-with-jq =
  !f() {
    cat "${1}" | jq 'tostring'
  }; f

authorize-my-ip =
  !f() {
    ip=$(aws myip)
    aws ec2 authorize-security-group-ingress --group-id ${1} --cidr $ip/32 --protocol tcp --port 22
  }; f

get-group-id =
  !f() {
    aws ec2 describe-security-groups --filters Name=group-name,Values=${1} --query SecurityGroups[0].GroupId --output text
  }; f

authorize-my-ip-by-name =
  !f() {
    group_id=$(aws get-group-id "${1}")
    aws authorize-my-ip "$group_id"
  }; f

# list all security group port ranges open to 0.0.0.0/0
public-ports = ec2 describe-security-groups \
  --filters Name=ip-permission.cidr,Values=0.0.0.0/0 \
  --query 'SecurityGroups[].{
    GroupName:GroupName,
    GroupId:GroupId,
    PortRanges:
      IpPermissions[?contains(IpRanges[].CidrIp, `0.0.0.0/0`)].[
        join(`:`, [IpProtocol, join(`-`, [to_string(FromPort), to_string(ToPort)])])
      ][]
  }'

# List or set your region
region = !f() { [[ $# -eq 1 ]] && aws configure set region "$1" || aws configure get region; }; f

find-access-key = !f() {
    clear_to_eol=$(tput el)
    for i in $(aws iam list-users --query "Users[].UserName" --output text); do
      printf "\r%sSearching...$i" "${clear_to_eol}"
      result=$(aws iam list-access-keys --output text --user-name "${i}" --query "AccessKeyMetadata[?AccessKeyId=='${1}'].UserName";)
      if [ -n "${result}" ]; then
         printf "\r%s%s is owned by %s.\n" "${lear_to_eol}" "$1" "${result}"
         break
      fi
    done
    if [ -z "${result}" ]; then
      printf "\r%sKey not found." "${clear_to_eol}"
    fi
  }; f

docker-ecr-login =
  !f() {
    region=$(aws configure get region)
    endpoint=$(aws ecr get-authorization-token --region $region --output text --query authorizationData[].proxyEndpoint)
    passwd=$(aws ecr get-authorization-token --region $region --output text --query authorizationData[].authorizationToken | base64 --decode | cut -d: -f2)
    docker login -u AWS -p $passwd $endpoint
  }; f

myip =
  !f() {
    dig +short myip.opendns.com @resolver1.opendns.com
  }; f

allow-my-ip =
  !f() {
    my_ip=$(aws myip)
    aws ec2 authorize-security-group-ingress --group-name ${1} --protocol ${2} --port ${3} --cidr $my_ip/32
  }; f

revoke-my-ip =
  !f() {
    my_ip=$(aws myip)
    aws ec2 revoke-security-group-ingress --group-name ${1} --protocol ${2} --port ${3} --cidr $my_ip/32
  }; f

allow-my-ip-all =
  !f() {
    aws allow-my-ip ${1} all all
  }; f

revoke-my-ip-all =
  !f() {
    aws revoke-my-ip ${1} all all
  }; f


list-instances =
  !f() {
    echo "Filtering by \`$1\`"
    for region in us-west-2 us-east-2
      do
        echo "\nListing Instances in region:'$region'..."
        aws ec2 describe-instances --region $region \
          --output table \
	  --filters Name=instance-state-name,Values=running \
          --query "Reservations[*].Instances[*].{
                    Instance:InstanceId,
		    ID: InstanceId,
		    Instance:ImageId,
                    Type:InstanceType,
                    AZ:Placement.AvailabilityZone,
                    Name:Tags[?Key==\`Name\`]|[0].Value,
                    IP:PrivateIpAddress,
                    State:State.Name
                }"
      done
  }; f


get-target =
  !f() {
    aws elbv2 describe-target-groups --output table | grep TargetGroupArn | grep ${1} | grep -v green | grep ${2} | cut -d "|" -f4
  }; f

get-target-groups =
  !f() {
    aws elbv2 describe-target-groups --output table | grep TargetGroupArn | grep ${1} | grep -v green | cut -d "|" -f4
  }; f

takeout-node =
  !f() {
    aws elbv2 deregister-targets --target-group-arn ${2} --targets Id=${1}
  }; f