#!/bin/bash


rpm -i http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm
yum install -y puppet puppet-server
yum install -y puppetdb-terminus puppetdb




#config puppet master



cat << EOF > /etc/puppet/puppet.conf
[main]
    logdir = /var/log/puppet
    rundir = /var/run/puppet
    ssldir = $vardir/ssl
	environmentpath = /etc/puppet/environments

[master]
    node_terminus = exec
    external_nodes = /opt/nodeclassifier/enc.rb
    dns_alt_names = puppet,puppetmaster,puppetmaster.localdomain
    autosign = true
    storeconfigs = true
    storeconfigs_backend = puppetdb

[agent]
    classfile = $vardir/classes.txt
    localconfig = $vardir/localconfig
    server = puppetmaster
    report = true
EOF

cat << EOF > /etc/puppet/autosign.conf
*
EOF

cat << EOF > /etc/puppet/routes.yaml
---
master:
  facts:
    terminus: puppetdb
    cache: yaml
EOF

cat << EOF > /etc/puppet/puppetdb.conf
[main]
server = puppetmaster
port = 8081
EOF

# Configure hiera.yaml
#TODO:
cat << EOF > /etc/puppet/hiera.yaml
---
:backends:
  - eyaml
  - yaml
:hierarchy:
  - "node/%{::fqdn}"
  - "env/%{::environment}"
  - common
:yaml:
  :datadir: "/etc/puppet/environments/%{::environment}/hieradata"
:eyaml:
  :datadir: "/etc/puppet/environments/%{::environment}/hieradata"
  :extension: 'yaml'
  :pkcs7_private_key: /var/lib/puppet/keys/private_key.pkcs7.pem
  :pkcs7_public_key:  /var/lib/puppet/keys/public_key.pkcs7.pem
EOF

# Install hiera-eyaml
gem install hiera-eyaml

# Ensure correct permissions
chown -R puppet:puppet `puppet config print confdir`

# Start puppetmaster
chkconfig puppetmaster on
service puppetmaster start

# Start puppetdb
/usr/sbin/puppetdb ssl-setup # This needs to be *after* starting the puppetmaster as it takes a copy of keys generated by it.
chkconfig puppetdb on
service puppetdb start

chkconfig puppet on
service puppet start

chown puppet:puppet /var/lib/puppet/keys/ -R
chmod 600 /var/lib/puppet/keys/*

echo "search localdomain" > /etc/resolv.conf
echo "nameserver 10.0.2.3" >> /etc/resolv.conf


