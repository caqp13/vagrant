#!/bin/bash
echo "search localdomain" > /etc/resolv.conf
echo "nameserver 10.0.2.3" >> /etc/resolv.conf


rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm
#yum --nogpgcheck localinstall http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm

yum install -y puppet
chkconfig puppet on
service puppet start
