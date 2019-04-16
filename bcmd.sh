#!/bin/bash  
date=`date "+%H:%M:%S"`
RED='\033[31m'
GRE='\033[32m'
BLU='\033[34m'
CLO='\033[0m'
user=$1
file_name=$2                                         
cmd_str=$3                                           
cwd=$(pwd)                                           
cd $cwd                                         
THREAD=10
SLEEP_TIME=2                                        
serverlist_file="$cwd/$file_name"
	  function my_log()
	  {
		  if [[ $1 =~ "ERROR" ]];then
			echo  -e "${RED} [$date] $1 ${CLO}"  2>&1 | tee -a $logfile
		  elif [[ $1 =~ "INFO" ]];then 
			echo  -e "${GRE} [$date] $1 ${CLO}"  2>&1 | tee -a $logfile
		  else
			echo  -e "${BLU}[$date] $1 ${CLO}"  2>&1 | tee -a $logfile 
		   fi
	  }
	  
	function  sub(){
	 #my_log "INFO:休息 ${SLEEP_TIME}秒"
	sleep ${SLEEP_TIME};
	}


TMPFIFO=/tmp/$$.fifo
mkfifo $TMPFIFO
exec 5<>${TMPFIFO}
rm -f $TMPFIFO
	 for((i=1;i<=$THREAD;i++))
	 do
		echo "" >&5      
	 done
 
[ "$#" -ne 3 ] && my_log "ERROR:USAGE: $0 user server_list_file cmd" 	&& exit 1
[ ! -e $serverlist_file ]  && my_log "ERROR: server.list not exist;"   && exit 2  
#cat $serverlist_file |grep -vE "^$|^#"|while read line                                    
for line in $(cat $serverlist_file |grep -vE "^$|^#")
do                                                   
	read -u5  
    #echo $line  
{                          
    if [ -n "$line" ] ; then                         
        my_log " 开始执行--->>>>> $line <<<<<<< "         
        sudo ssh -o StrictHostKeyChecking=no -o GSSAPIAuthentication=no -o ConnectTimeout=5 -n $user@$line $cmd_str
        if [ $? -eq 0 ] ; then                       
            my_log "INFO: $line $cmd_str 执行成功 "                    
        else                                         
            my_log "ERROR: $line $cmd_str 执行失败!!! " $?                        
        fi                                           
    fi
sub  
echo "" >&5 
} &
                                                 
done
wait 
exec 5>&- 
exit 0 
