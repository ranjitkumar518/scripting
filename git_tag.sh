#!/bin/bash

echo "******** You need GIT and Token access to https://github.intuit.com/ to run this script  ********" | tr '/a-z/' '/A-Z/'
echo "******** Kindly Make Sure the First Parameter is the TAG & Second Parameter is BRANCH ********" | tr '/a-z/' '/A-Z/'
echo ""

ALLOWEDBRANCH="master | develop | integration | e2e | stage | performance" #branches allowed
TAG=$1
BRANCH=$2
DIR=$PWD

gittag() {

	TAG=$1
	BRANCH=$2
	REPO=$3

	mkdir repo
	cd repo
	git clone $REPO
	cd $(echo $REPO | cut -d / -f 5 | sed 's/.git//g')
	git checkout $BRANCH
	git tag $TAG
	git push origin $TAG
	cd $DIR
	rm -rf repo*
}

if [[ "$#" -ne 2 ]]
then
echo "kinly pass exactly 2 Arguments and update the $https_repo_url1.git"
exit
fi

if [[ -z $TAG || -z $BRANCH ]]
then
echo "One or both the Arguments you gave have null value and update the $https_repo_url1.git"
exit
fi

if [[ ! $ALLOWEDBRANCH =~ $BRANCH ]];
then
echo "Branch $BRANCH is not allowed, Allowed Branchs are master,integration,develop,perfomrance,e2e and stage"
exit
fi

gittag $TAG $BRANCH $https_repo_url1.git

gittag $TAG $BRANCH $https_repo_url2.git

gittag $TAG $BRANCH $https_repo_url3.git

gittag $TAG $BRANCH $https_repo_url4.git

gittag $TAG $BRANCH $https_repo_url5.git

echo "********Tagging Complete, Check Error On Standard Output********"
