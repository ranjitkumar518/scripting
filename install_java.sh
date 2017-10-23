#####Version 1.1 ############
####Script is used to install/remove java in the system####

#####How to run######
##./install_java.sh#####
#######################


#####Variables#########
FILE="/tmp/`md5sum /proc/self/status | awk '{print $1}'`"
COUNT=1
IFS1=$IFS
IFS=$'\n'

###Functions#####

readdef () {
    # The variable name being set gets passed in as first argument, the text
    # of the question/prompt as the second and the optional default answer
    # passed in as third argument.  Pressing just <enter> results in the
    # default being returned. If the answer SHOULD be empty, then user
    # should supply a single '-' to clear the default and return "".
    VARNAME=$1
    QUESTION=$2
    REQUIRED=$3
    DEFANSWER=$4
    eval "CURVAL=\$$VARNAME"
    if [ -n "$CURVAL" ]; then
        DEFANSWER="$CURVAL"
    fi
    echo -n "$QUESTION [$DEFANSWER]: "
    read RESPONSE
    if [ -z "$RESPONSE" ]; then
        eval "$VARNAME=\"\$DEFANSWER\""
    else
        if [ "$RESPONSE" = "-" ]; then
            eval "$VARNAME=\"\""
        else
            eval "$VARNAME=\"\$RESPONSE\""
        fi
    fi
    if [ "$REQUIRED" -gt 0 ]; then
           eval "VARVALUE=\$$VARNAME"
           if [ -z "$VARVALUE" ]; then
            readdef $VARNAME "$QUESTION" $REQUIRED $DEFANSWER
        fi
    fi
}
###To add jdk/jre####
add () {
  >$FILE
  while [ $RESPONSE != 'jdk' -a  $RESPONSE != 'jre' ] ; do
    echo "Do  you want to install jdk or jre [jdk|jre]"
    read RESPONSE
    if [ -z $RESPONSE ]; then
      echo "Error!!!!! Input can't be blank"
      RESPONSE=n; ##Reset the count
    fi
    if [ $RESPONSE != 'jdk' -a $RESPONSE != 'jre' ]; then
      echo "Error!!!!! Incorrect input, please try again"
    fi
  done
  yum list ${RESPONSE}32* ${RESPONSE}64* ${RESPONSE}* | egrep "^$RESPONSE(32|64)" | grep -v installed >/dev/null
  if [ $? -eq 0 ]; then
    echo "Following $RESPONSE versions are available to install"
        for i in  `yum list ${RESPONSE}32* ${RESPONSE}64* ${RESPONSE}* | egrep "^$RESPONSE(32|64)" | grep -v installed| awk '{print $1}'`; do
        echo $COUNT $i | tee -a $FILE
        (( COUNT += 1 ))
    done
    readdef OPTION "Select java version which you want to install, Please choose option [1,2,3,4..etc]" 1
    install
  else
    echo "No $RESPONSE available in repository"
    rm -f $FILE > /dev/null 2>&1
    exit 1
  fi
}

install ()
{
       echo $OPTION
        VAR=`cat $FILE | grep -iw ^$OPTION| awk '{print $2}'`
        if [ -z $VAR ] ; then
               COUNT=1
                add
        fi
        yum install -y $VAR
        if [ $? -eq 0 ]; then
           echo "$VAR is sucessfully installed on your system"
           rm -f $FILE > /dev/null 2>&1
                   exit 0
        fi

}

remove ()
{
     >$FILE
          while [ $RESPONSE != 'jdk' -a  $RESPONSE != 'jre' ]
                do
                  echo "Do  you want to remove jdk or jre [jdk|jre]"
                  read RESPONSE

                 if [ -z $RESPONSE ]; then
                  echo "Error!!!!! Input can't be blank"
                   RESPONSE=n; ##Reset the count
                   fi
                if [ $RESPONSE != 'jdk' -a $RESPONSE != 'jre' ]
                   then
                   echo "Error!!!!! Incorrect input, please try again"
                fi
                done
                available_packages=''

               yum list ${RESPONSE}32* ${RESPONSE}64* ${RESPONSE}* | egrep "^$RESPONSE(32|64)"| grep installed  >/dev/null
                if [ $? -eq 0 ]
                   then
                    echo "Following $RESPONSE versions installed in your system"
                    for i in  `yum list ${RESPONSE}32* ${RESPONSE}64* ${RESPONSE}* | egrep "^$RESPONSE(32|64)"| grep installed | awk '{print $1}'`
                   do
                     echo $COUNT $i | tee -a $FILE
                     (( COUNT += 1 ))
                   done
                readdef OPTION "Select java version which you want to un-install, Please choose option [1,2,3,4..etc]" 1
                uninstall
                  else
                 echo " No $RESPONSE installed in your system"
                           rm -f $FILE > /dev/null 2>&1
                           exit 1
             fi
}

uninstall ()
{
        VAR=`cat $FILE | grep -i ^$OPTION| awk '{print $2}'`
        if [ -z $VAR ] ; then
                COUNT=1
                remove
        fi
        yum remove $VAR
        if [ $? -eq 0 ]; then
           echo "$VAR is sucessfully removed from your system"
           rm -f $FILE > /dev/null 2>&1
                   exit 0
        fi
}

main ()
{

USER=`whoami`

if [ $USER != 'root' ];then
        echo "Switching to root. You may be prompted for your password."
        exec sudo $0
fi

RESPONSE=n
  while [ $RESPONSE != 'add' -a  $RESPONSE != 'rem' ]
do
       echo "Do you want to add or remove the package, Please input  [add/rem]"
        read RESPONSE
         if [ -z $RESPONSE ]; then
         echo "Error !!!!!! Input can't be blank"
         RESPONSE=n; ##Reset the count
         fi
         if [ $RESPONSE != 'add' -a $RESPONSE != 'rem' ]
             then
              echo "Error !!!!! Incorrect input, please try again"
              fi
done


#      echo "Do you want to add/rem  [add/rem]"
#       read RESPONSE

                if [ $RESPONSE == 'add' ];then
                        add
                else
                        remove
                fi
}
#########calling main########
main
