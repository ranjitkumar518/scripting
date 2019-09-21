#!/bin/bash
AWS_PROFILE=$1
ENV=$2
COMPONENTS=$3
TTL=$4
TYPE="CNAME"

# Checking Parameter

if [[ -z "$AWS_PROFILE" && "$AWS_PROFILE" = '' ]]
then
echo "AWS_PROFILE is missing"
echo "./updatednsttl.sh <AWS_PROFILE> <ENV>[prd,dev] <COMPONENTS>[component1,component2,component3,all] <TTL>"
exit -1;
fi

if [[ -z "$ENV" && "$ENV" = '' ]]
then
echo "Env is missing."
echo "./updatednsttl.sh <AWS_PROFILE> <ENV>[prd,dev] <COMPONENTS>[component1,component2,component3,all] <TTL>"
exit -1;
fi

if [[ -z "$COMPONENTS" && "$COMPONENTS" = '' ]]
then
echo "COMPONENTS is missing"
echo "./updatednsttl.sh <AWS_PROFILE> <ENV>[prd,dev] <COMPONENTS>[component1,component2,component3,all] <TTL>"
exit -1;
fi

if [[ -z "$TTL" && "$TTL" = '' ]]
then
echo "TTL is missing"
echo "./updatednsttl.sh <AWS_PROFILE> <ENV>[prd,dev] <COMPONENTS>[component1,component2,component3,all] <TTL>"
exit -1;
fi

# Private Zone Components
PVT_COMPONENTS="^($private_component1|$private_component2|$private_component3|$private_component4)$"

# Checking Zone ID based on COMPONENTS
case $ENV in

    prd)
        if [[ "$COMPONENTS" =~ $PVT_COMPONENTS  ]]
        then
            # Prod Private Zone
            ZONE_ID="$ZONE_ID"
            DOMAIN_SUFFIX="$Zone_NAME"
        else
            # Prod Public Zone
            ZONE_ID="$ZONE_ID"
            DOMAIN_SUFFIX="$Zone_NAME"
        fi
    ;;
    e2e|stage|prf*)
        if [[ "$COMPONENTS" =~ $PVT_COMPONENTS ]]
        then
            # PreProd Private Zone
            ZONE_ID="$ZONE_ID"
            DOMAIN_SUFFIX="$Zone_NAME"
        else
            # PreProd PUblic Zone
            ZONE_ID="$ZONE_ID"
            DOMAIN_SUFFIX="$Zone_NAME"
        fi
    ;;
    *)
            # PreProd PUblic Zone
            ZONE_ID="$ZONE_ID"
            DOMAIN_SUFFIX="$Zone_NAME"
     ;;
esac

# Printing the Input Values
echo -e "ZoneID:$ZONE_ID\n"
echo -e "Domain Suffix: $DOMAIN_SUFFIX\n"
echo -e "Environment: $ENV\n"
echo -e "Service/Components: $COMPONENTS\n"
echo -e "TTL: $TTL\n"

# Getting All DNS Records from Route53 based in the given hosted zone id
aws --profile default route53 list-resource-record-sets --hosted-zone-id $ZONE_ID   --query "ResourceRecordSets[*].[Name,ResourceRecords]" --output text  >  /tmp/list-resource-record-sets.txt

# Executing All Public components
if [ "$COMPONENTS" = "all" ]
then
cat /tmp/list-resource-record-sets.txt | grep -E "$ENV"  > /tmp/filter-dns-list.txt
else

# Filtering WEB_Component(ABCD) [OR] INTERNAL(abcd) where abc is R53 record start string
cat /tmp/list-resource-record-sets.txt | grep -E "(abc-)?$COMPONENTS|(abcd-)?abcd-$COMPONENTS" | grep -E "$ENV"  > /tmp/filter-dns-list.txt
fi

# Rearrange RESOURCERECORDSETS and RESOURCERECORDS
cat /tmp/filter-dns-list.txt | awk 'NR%2{printf "%s,",$0;next;}1' |  tr -d " \t" > /tmp/RECORDS.csv


cat /tmp/RECORDS.csv | while read line
do

DOMAIN=$(echo $line | cut -d "," -f 1)
ELB=$(echo $line | cut -d "," -f 2)

echo $DOMAIN
echo $ELB

TMPFILE=$(mktemp /tmp/temporary-file.XXXXXXXX)

cat > ${TMPFILE} << EOF
    {
      "Comment":"Changing TTL to $TTL",
      "Changes":[
        {
          "Action":"UPSERT",
          "ResourceRecordSet":{
            "ResourceRecords":[
		{
		   "Value":"$ELB"
		}
	     ],
            "Name":"$DOMAIN",
            "Type":"$TYPE",
            "TTL":$TTL
          }
        }
        ]
   }
EOF

aws --profile $AWS_PROFILE route53 change-resource-record-sets --hosted-zone-id $ZONE_ID --change-batch file://"$TMPFILE"

done

#rm /tmp/temporary-file.*
