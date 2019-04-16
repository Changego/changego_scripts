#!/bin/bash
bin_path=/opt/zedis

function my_usage()
{
	cat << EOF
Usage: $0 [OPTIONS]
Valid options are:
 -h       sentinel ip
 -p       sentinel port
EOF
}

function my_log()
{
	echo "`date "+%Y-%m-%d %H:%M:%S"` $1" 2>&1 | tee -a $logfile
}


while getopts "h:p:H" opt; do
	case $opt in
	h) host=$OPTARG;;
	p) port=$OPTARG;;
	H) my_usage;exit 0;;
	\?)my_usage;exit 1;;
	esac
done

if [ -z "$host" -o  -z "$port" ]; then
	my_usage;
	exit 1
fi

if [ ! -f $bin_path/redis-cli ]; then
	my_log "ERROR:binary file path error"
	exit 3
fi

add_key=`tr -dc "0-9a-zA-Z" < /dev/urandom|head -c 10`

for ((i=0;i<1000;i++))
do
echo -en "hello:${add_key}" | $bin_path/redis-cli  -h $host -p $port -x set chang:${i}
echo -en "hello:${add_key}" | $bin_path/redis-cli -h $host -p $port -x hmset chang_key:${i} chang_hash:${i} chang_hash:${i} chang_hash:${i} 
$bin_path/redis-cli -h $host -p $port EXPIRE chang:${i} 996
$bin_path/redis-cli -h $host -p $port EXPIRE chang_key:${i} 996
done
