#!/bin/bash

echo "******** You need GIT and Token access to https://github.abcd.com/ to run this script  ********" | tr '/a-z/' '/A-Z/'
echo "******** Kindly Make Sure the First Parameter is the BASE branch to which pull request is created ********" | tr '/a-z/' '/A-Z/'
echo ""

ALLOWEDBRANCH="master | develop | integration | stage | e2e | performance" #branches allowed
BASE=$1
BRANCH=$2
DIR=$PWD

getlog() {

	BASE=$1
	BRANCH=$2
	REPO=$3

	mkdir repo
	cd repo
	git clone $REPO
	cd $(echo $REPO | cut -d / -f 5 | sed 's/.git//g')
	git checkout $BASE
	git checkout $BRANCH
	echo "" >> ~/GitLogDiff.txt
	echo "******************************$(echo $REPO | cut -d / -f 5 | sed 's/.git//g')******************************" | tr '/a-z/' '/A-Z/' >> ~/GitLogDiff.txt
	#git log --oneline $BASE..$BRANCH | cut -d " " -f 2- | grep -v Revert | grep -v Merge | sed -e 's/(#[0-9]*)//g' | sed -e 's/#[0-9]*//g' | sort -u >> ~/GitLogDiff.txt
	git log --oneline $BASE..$BRANCH | cut -d " " -f 2- | grep -v Revert | grep -v Merge >>  ~/GitLogDiff.txt
        echo "****************$(echo $REPO | cut -d / -f 5 | sed 's/.git//g')*************" | tr '/a-z/' '/A-Z/' >> ~/GitLogDiff.txt
	echo "" >> ~/GitLogDiff.txt
	echo ""
	cd $DIR
	rm -rf repo*
}

if [[ "$#" -ne 2 ]]
then
echo "kinly pass exactly 2 Arguments"
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

echo "" > ~/GitLogDiff.txt
echo "******************************date:$(date +'%Y-%m-%d')******************************" | tr '/a-z/' '/A-Z/' >> ~/GitLogDiff.txt
echo "" >> ~/GitLogDiff.txt
echo "******************************$BASE and $BRANCH******************************" | tr '/a-z/' '/A-Z/' >> ~/GitLogDiff.txt
echo "" >> ~/GitLogDiff.txt

getlog $BASE $BRANCH https://$repo_url1.git

getlog $BASE $BRANCH https://$repo_url2.git

getlog $BASE $BRANCH https://$repo_url3.git

getlog $BASE $BRANCH https://$repo_url4.git


echo "******** LOOK FOR FILE GitLogDiff.txt IN YOUR HOME DIRECTORY ********"
