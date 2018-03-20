#!/bin/bash
rm -rf ss_reload
Get_Dist_Name()
{
    if grep -Eqii "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release; then
        DISTRO='CentOS'
        PM='yum'
    elif grep -Eqi "Red Hat Enterprise Linux Server" /etc/issue || grep -Eq "Red Hat Enterprise Linux Server" /etc/*-release; then
        DISTRO='RHEL'
        PM='yum'
    elif grep -Eqi "Aliyun" /etc/issue || grep -Eq "Aliyun" /etc/*-release; then
        DISTRO='Aliyun'
        PM='yum'
    elif grep -Eqi "Fedora" /etc/issue || grep -Eq "Fedora" /etc/*-release; then
        DISTRO='Fedora'
        PM='yum'
    elif grep -Eqi "Debian" /etc/issue || grep -Eq "Debian" /etc/*-release; then
        DISTRO='Debian'
        PM='apt'
    elif grep -Eqi "Ubuntu" /etc/issue || grep -Eq "Ubuntu" /etc/*-release; then
        DISTRO='Ubuntu'
        PM='apt'
    elif grep -Eqi "Raspbian" /etc/issue || grep -Eq "Raspbian" /etc/*-release; then
        DISTRO='Raspbian'
        PM='apt'
    else
        DISTRO='unknow'
    fi
}
Get_Dist_Name
$PM update -y && $PM upgrade -y
$PM install gcc libtool lrzsz -y
mkdir ss_reload
cd ss_reload
cd ..
if [ "$DISTRO" == "CentOS" ] || [ "$DISTRO" == 'RHEL' ]; then
    $PM install libcurl
	wget http://repo.zabbix.com/zabbix/3.4/rhel/7/x86_64/zabbix-agent-3.4.2-1.el7.x86_64.rpm
	rpm -i zabbix-agent-3.4.2-1.el7.x86_64.rpm
elif [ "$DISTRO" == "Debian" ]; then
    $PM install libcurl3
	wget http://repo.zabbix.com/zabbix/3.4/debian/pool/main/z/zabbix/zabbix-agent_3.4.2-1+jessie_amd64.deb
	dpkg -i zabbix-agent_3.4.2-1+jessie_amd64.deb
elif [ "$DISTRO" == "Ubuntu" ]; then
    $PM install libcurl3
	wget http://repo.zabbix.com/zabbix/3.4/ubuntu/pool/main/z/zabbix/zabbix-agent_3.4.2-1+xenial_amd64.deb
	dpkg -i zabbix-agent_3.4.2-1+xenial_amd64.deb
fi
wget http://cj.c109.net/zabbix_agentd.conf
mv -f zabbix_agentd.conf /etc/zabbix/zabbix_agentd.conf

wget http://cj.c109.net/ss-panel_v3.sh
chmod +x ss-panel_v3.sh
./ss-panel_v3.sh
ssh-keygen
cd /root/.ssh
mv *.pub ./authorized_keys
read -p "输入刚才私钥的文件名: " key
sz ./$key
read -p "更改ssh端口为: " ssh_port
sed -i 's/\(# *Port \)22/\${ssh_port}/' /etc/ssh/sshd_config
iptables -I INPUT -p tcp -m tcp --dport 10050 -j ACCEPT
iptables -I INPUT -p tcp -m tcp --dport $ssh_port -j ACCEPT
iptables-save >/etc/sysconfig/iptables
echo 'iptables-restore /etc/sysconfig/iptables' >> /etc/rc.local
echo "/usr/bin/supervisord -c /etc/supervisord.conf" >> /etc/rc.local
chmod +x /etc/rc.d/rc.local
sleep 4
zabbix_agentd
service sshd restart