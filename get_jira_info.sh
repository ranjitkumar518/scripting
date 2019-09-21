#!/bin/bash

echo "******** You need GIT and Token access to https://github.abcd.com/ to run this script  ********" | tr '/a-z/' '/A-Z/'
echo "******** Kindly Make Sure the First Parameter is the BASE branch to which pull request is created ********" | tr '/a-z/' '/A-Z/'
echo "********Script requires Jq to parse json. To install run: brew install jq ********"
echo "********Script requires mail utility to send mails********"

rm ~/output.txt
rm ~/GitLogDiff.txt
rm -f ~/output.csv
rm -f ~/output.html

echo "Please enter your Jira password"
stty -echo
read PASSWORD;
stty echo

ALLOWEDBRANCH="master | develop | integration | stage | e2e | performance" #branches allowed
BASE=$1
BRANCH=$2
DIR=$PWD
USERNAME=$3

getlog() {

	BASE=$1
	BRANCH=$2
	REPO=$3
	USERNAME=$4
	PASSWORD=$5
  jira=abcd
  
	mkdir repo
	cd repo
	git clone $REPO
	cd $(echo $REPO | cut -d / -f 5 | sed 's/.git//g')
	git checkout $BASE
	git checkout $BRANCH
	git log --oneline $BASE..$BRANCH | cut -d " " -f 2- | grep -v Revert | grep -v Merge | awk '{print $1}' | cut -c1-10 | grep "$jira-" | sort | uniq  >  ~/GitLogDiff.txt
	FILE=~/GitLogDiff.txt
	echo "******************************$(echo $REPO | cut -d / -f 5 | sed 's/.git//g')******************************" | tr '/a-z/' '/A-Z/' >> ~/output.txt
	echo "Jira_Id,Jira_Assignee,Fix_Version,Jira_Summary" >> ~/output.txt
	while read Line
	do
		echo $Line
		curl -u $USERNAME:$PASSWORD -X GET -H "Content-Type: application/json" https://jira.abcd.com/rest/api/latest/issue/$line  > /tmp/jira.json
		Jira_Summary=`cat /tmp/jira.json | jq ".fields.summary"`
		Jira_Assignee=`cat /tmp/jira.json | jq ".fields.assignee.name"`
		Jira_Fix_Version=`cat /tmp/jira.json | jq ".fields.fixVersions[0].name"`
		echo "$Line,$Jira_Assignee,$Jira_Fix_Version,$Jira_Summary" >> ~/output.txt
 	done < $FILE
	cd $DIR
	rm -rf repo*
}

if [[ "$#" -ne 3 ]]
then
echo "kinly pass exactly 4 Arguments"
echo "Example: sh get_jira_info.sh master develop username"
exit
fi

if [[ -z $BASE || -z $BRANCH ]]
then
echo "One or both the branches you gave null value"
exit
fi

if [[ ! $ALLOWEDBRANCH =~ $BASE ]];
then
echo "Branch $BASE is not allowed, Allowed Branchs are master,integration,develop"
exit
fi

if [[ ! $ALLOWEDBRANCH =~ $BRANCH ]];
then
echo "Branch $BRANCH is not allowed, Allowed Branchs are master,integration,develop"
exit
fi


getlog $BASE $BRANCH https://$git_hub_url.git $USERNAME $PASSWORD

getlog $BASE $BRANCH https://$git_hub_url.git $USERNAME $PASSWORD

getlog $BASE $BRANCH https://$git_hub_url.git $USERNAME $PASSWORD

getlog $BASE $BRANCH https://$git_hub_url.git $USERNAME $PASSWORD

getlog $BASE $BRANCH https://$git_hub_url.git $USERNAME $PASSWORD

getlog $BASE $BRANCH https://$git_hub_url.git $USERNAME $PASSWORD


cat ~/output.txt > ~/output.csv

gawk 'BEGIN{
FS=","
print  "MIME-Version: 1.0"
print  "Content-Type: text/html"
print  "Content-Disposition: inline"
print  "<HTML>""<TABLE border="1">"
#print  "<HTML>""<TABLE border="1"><TH>Heading1</TH><TH>Heading2</TH><TH>Heading3</TH>"
}
 {
printf "<TR>"
for(i=1;i<=NF;i++)
printf "<TD>%s</TD>", $i
print "</TR>"
 }
END{
print "</TABLE></BODY></HTML>"
 }
' ~/output.csv > ~/output.html

echo "******** LOOK FOR FILE output.csv/output.html in home directory ********"
mail -s "$(echo "Change log between $BASE and $BRANCH for the Targeted Release \nContent-Type: text/html")"  mail_id1@abcd.com, mail_id2@abcd.com <  ~/output.html
