#!/bin/sh
dldir=$1
listpath=$2
urltype=$3
thread_num=5
video=`awk '{print NR}' ${listpath}|tail -n1`
cd $dldir
if [ 0 -ne `ps -ef |grep youtube-dl |grep -v "grep" |wc -l` ]
then
	echo "有下载任务没完成，请稍等。。。"
fi
while [ 0 -ne `ps -ef |grep youtube-dl |grep -v "grep" |wc -l` ]
do
	if [0 -eq `ps -ef |grep youtube-dl |grep -v "grep" |wc -l` ]
	then
        	break
	fi
done
if [ `ls ${dldir}|wc -l` -ne 0 ]
then
	rm -rf *
fi
function down1(){
	url=`cat ${listpath}`
	echo "请选择："
	echo "1.下载最高画质"
	echo "2.选择单音频单画质的组合"
	read choose
	case $choose in
	2)
	youtube-dl -F $url
	echo "请输入音频："
	read audio
	echo "请输入视频："
	read video
	youtube-dl -c -f ${video}+${audio} $url
	;;
	1)
	youtube-dl -c $url
	;;
	esac
}
function down2(){
	youtube-dl -c -a $listpath
}
function down3(){
	apt install aria2 -y
	echo "输入nico账号："
	read account
	echo "输入密码："
	read password
	temp_fofo_file=$$.info
	mkfifo $temp_fofo_file
	exec 6<>$temp_fofo_file
	rm $temp_fofo_file
	for (( i = 0; i < $thread_num; i++ )); do
		echo
	done > &6
	for line in `cat $listpath`; do
		{
	youtube-dl --external-downloader aria2c --external-downloader-args "-x 8  -k 1M" -i -c $line -u ${account} -p ${password}
		} &
	done < &6

	wait
	exec 6>&-
}
down3
