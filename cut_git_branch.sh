#!/bin/bash -e

SOURCE="rc_stable"
DESTINATION="rc_stable_new"

# If source is not defined, defaults to develop
if [[ -z "$SOURCE" && "$SOURCE" = '' ]]
then
SOURCE="develop"
fi

if [[ -z "$DESTINATION" && "$DESTINATION" = '' ]]
then
echo "Destination Branch name is missing"
fi

if [[ "$BUILDER_TYPE" == "ci"  || "$BUILDER_TYPE" == "periodic" ]]
then
    dt=$(date '+%m_%d_%Y')
    DESTINATION="rc_${BUILDER_TYPE}_${dt}"
fi

echo "SOURCE: $SOURCE"
echo "DESTINATION: $DESTINATION"
echo "BUILDER_TYPE $BUILDER_TYPE"


createBranch() {
    REPO=$1
    echo  "Cloning git@github.abcd.com:organization/$REPO.git";
    rm -rf $REPO

    if [ ! -z "$BUILDER_TYPE" ]; then
      echo "Setting User and Credential"
      echo ${GIT_PWD} > /tmp/gitcredfile
      trap "shred -n 25 -u -z /tmp/gitcredfile" EXIT
      git config --global user.name "cicd" --quiet
      git config --global user.email cicd@abcd.com --quiet
      git config --global credential.helper "store --file=/tmp/gitcredfile" --quiet
      git init --quiet
    else
      echo  "Local Build"
    fi

    git clone git@github.abcd.com:organization/$REPO.git
    if [ $? -ne 0 ]; then
       echo "Git Clone Error for $REPO....."
       exit 1;
    fi
    cd $REPO
    git checkout  $SOURCE
    git pull
    git branch $DESTINATION
    git checkout  $DESTINATION
    git push --set-upstream origin $DESTINATION

    if [ $? -ne 0 ]; then
       echo "Git Push Error for $REPO ....."
       exit 1;
    fi
    rm -rf $REPO
}

createBranch  repo1
createBranch  repo2
createBranch  repo3
createBranch  repo4
createBranch  repo5

echo "Completed..."
