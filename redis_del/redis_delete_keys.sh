#!/bin/bash
syspath=`dirname $0`
cd $syspath
conf_path=$(pwd)/conf
logpath=$(pwd)/logs
keylist_file=${conf_path}/key.list
bin_path="/opt/redis"
port=6379
##################################################
Key_Num=`wc -l ${keylist_file} 2> /dev/null|awk '{print $1}' `
if [[ ${Key_Num}	-lt 1 ]]; then
	echo -e "\033[31m$(date +'%Y-%m-%d %H:%M:%S') ERROR:KEY配置文件为空或文件不存在!!!\033[0m"
	exit 1;
fi

Ip_Num=`wc -l ${conf_path}/ip.conf 2> /dev/null|awk '{print $1}' `
if [[ ${Ip_Num}	-lt 1 ]]; then
	echo -e "\033[31m$(date +'%Y-%m-%d %H:%M:%S') ERROR:IP配置文件为空或文件不存在!!!\033[0m"
	exit 2;
elif [[ ${Ip_Num} -lt 200 &&  ${Ip_Num} -gt 1 ]]; then
  	THREAD_NUM=${Ip_Num}
  	echo -e "\033[36m$(date +'%Y-%m-%d %H:%M:%S') 自动设置 并发:${THREAD_NUM} 执行清理任务......\033[0m" | tee -a $logpath/my_log.log
else 
	THREAD_NUM=200
	echo -e "\033[346$(date +'%Y-%m-%d %H:%M:%S') 自动设置 并发:${THREAD_NUM} 执行清理任务......\033[0m" | tee -a $logpath/my_log.log
fi
cat ${conf_path}/ip.conf|grep -vE "^$|^#" > ${conf_path}/ip_list_exec_$$

#THREAD_NUM=500
mkfifo $$_tmp
exec 10<>$$_tmp
for ((n=0;n<$THREAD_NUM;n++))
do
    echo -ne "\n" 1>&10
done

while read ip
do
    read -u 10
    {
       status=`$bin_path/redis-cli -h ${ip} -p ${port} ping  2>/dev/null`			
       if [[ "${status}" -eq "PONG" ]];then
         echo -e "\033[34m$(date +'%Y-%m-%d %H:%M:%S') $ip 开始清理Redis KEY\033[0m" | tee -a $logpath/my_log.log
         cat ${keylist_file} |grep -vE "^$|^#"|while read keylist
         do
         	${bin_path}/redis-cli -h ${ip} -p ${port}    -n 0 --scan --pattern "${keylist}" | xargs ${bin_path}/redis-cli -h ${ip} -p ${port}  -n 0 DEL  2>/dev/null && delres1=0 || delres1=1
         	if [[ $delres1 -eq 0 ]];then
         	   echo -e "\033[34m$(date +'%Y-%m-%d %H:%M:%S') $ip ${keylist} 清理Redis 成功\033[0m" | tee -a $logpath/my_log.log
         	else
         	   echo -e "\033[31m$(date +'%Y-%m-%d %H:%M:%S') ERROR:$ip ${keylist} 清理Redis 失败!!!\033[0m" | tee -a $logpath/my_log.log
         	fi
    	 done
       else
         echo -e "\033[31m$(date +'%Y-%m-%d %H:%M:%S') $ip 服务异常!!!\033[0m" | tee -a $logpath/my_log.log
       fi
        echo -ne "\n" 1>&10
    }&
done < "${conf_path}/ip_list_exec_$$"
wait
rm  -f $$_tmp
rm  -f ${conf_path}/ip_list_exec_$$
