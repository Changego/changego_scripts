#!/bin/bash
# allcmd.sh host_file_list  'rm /home/nuaazdh/tmp.txt'
user=root
file_name=$1
remote_dir=$2
files=$3
cwd=$(pwd)
cd $cwd
serverlist_file="$cwd/$file_name"
[[ "$#" -ne 3 ]] && [[ "$#" -ne 2  ]] && echo -e "\033[31mUSAGE: $0  缺少参数请检查!!!\033[0m "   && exit 1
[ ! -e $serverlist_file ]  && echo -e "\033[31m未找到配置文件，请检查';\033[0m"   && exit 2
if [ "$#" -eq 2 ];then
cat $serverlist_file |grep -vE "^$|^#"|while read line
do
	if [ -n "$line" ] ; then
	echo -e " \033[32m DOING--->>>>>" $line "<<<<<<< \033[0m"
        files=`echo $remote_dir|awk -F'/' '{print $NF}'`
	ssh -o StrictHostKeyChecking=no -o GSSAPIAuthentication=no -o ConnectTimeout=5 -n  $user@$line "curl -T $remote_dir ftp://192.168.241.12/chang/${line}${files} -u deploy:extdeploy"
	if [ $? -eq 0 ] ; then
		echo  -e " \033[32m $cmd_str done! \033[0m"
	else
		echo -e "\033[31merror: \033[0m " $?
	fi
fi
done
fi

if [ "$#" -eq 3 ];then
cat $serverlist_file |grep -vE "^$|^#"|while read line
do
    #echo $line
    
    if [ -n "$line" ] ; then
        echo -e " \033[32m DOING--->>>>>" $line "<<<<<<< \033[0m"
        ssh -o StrictHostKeyChecking=no -o GSSAPIAuthentication=no -o ConnectTimeout=5 -n  $user@$line "cd $remote_dir;curl -T $files ftp://192.168.241.12/chang/${line}${files} -u deploy:extdeploy"
        if [ $? -eq 0 ] ; then
            echo  -e " \033[32m $cmd_str done! \033[0m"
        else
            echo -e "\033[31merror: \033[0m " $?
        fi
    fi
done
fi
