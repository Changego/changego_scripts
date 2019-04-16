#!/bin/bash
# allcmd.sh host_file_list  'rm /home/nuaazdh/tmp.txt'
user=root
file_name=$1
cmd_str=$2
cwd=$(pwd)
cd $cwd
serverlist_file="$cwd/$file_name"
#[ "$#" -ne 2 ] && echo -e "\033[31mUSAGE: $0 -f server_list_file cmd\033[0m "   && exit 1
#[ ! -e $serverlist_file ]  && echo -e "\033[31mserver.list not exist';\033[0m"   && exit 2
cat $serverlist_file |grep -vE "^$|^#"|while read line
do
    #echo $line
    
    if [ -n "$line" ] ; then
        #echo -e " \033[32m DOING--->>>>>" $line "<<<<<<< \033[0m"
        #ssh -o StrictHostKeyChecking=no -o GSSAPIAuthentication=no -o ConnectTimeout=5 -n  $user@$line $cmd_str
	ping -w 1 -c 2 $line >/dev/null
        if [ $? -eq 0 ] ; then
            echo  -e " \033[32m $cmd_str done! \033[0m"
        else
            echo -e "\033[31merror: ${line}  \033[0m "
        fi
    fi
done

