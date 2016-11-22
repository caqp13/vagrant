#!/bin/bash
echo "search localdomain" > /etc/resolv.conf
echo "nameserver 10.0.2.3" >> /etc/resolv.conf
rm -rf /etc/yum.repos.d/*
yum clean all
rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-5.noarch.rpm

cat << EOF > /etc/yum.repos.d/local.repo

[local]
name=local
baseurl=http://puppetmaster/repo/rhel59
enabled=1
gpgcheck=0

EOF




yum install -y puppet
chkconfig puppet on
service puppet start


/packages/mq75/mqlicense.sh -accept -text_only
rpm -ivh /packages/mq75/MQSeriesRuntime-7.5.0-2.x86_64.rpm
rpm -ivh /packages/mq75/MQSeriesServer-7.5.0-2.x86_64.rpm
rpm -ivh /packages/mq75/MQSeriesJava-7.5.0-2.x86_64.rpm
rpm -ivh /packages/mq75/MQSeriesSDK-7.5.0-2.x86_64.rpm
rpm -ivh /packages/mq75/MQSeriesMan-7.5.0-2.x86_64.rpm
