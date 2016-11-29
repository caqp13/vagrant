#!/bin/bash
echo "search localdomain" > /etc/resolv.conf
echo "nameserver 10.0.2.3" >> /etc/resolv.conf


rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm
#yum --nogpgcheck localinstall http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm


cat << EOF > /etc/yum.repos.d/local.repo

[local]
name=local
baseurl=http://puppetmaster/repo/centos68
enabled=1
gpgcheck=0

EOF

yum clean all

yum install -y puppet

echo "    server = puppetmaster.localdomain" >> /etc/puppet/puppet.conf


chkconfig puppet on
service puppet start


