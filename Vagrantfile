# -*- mode: ruby -*-
# vi: set ft=ruby :

# Require greater than 1.7.3 to fix bug with running EL7 https://github.com/mitchellh/vagrant/pull/5709
Vagrant.require_version ">= 1.7.3"

# Install some useful plugins
#['vagrant-hostmanager', 'pry-byebug'].each do |plugin|
['vagrant-hostmanager'].each do |plugin|
  system "vagrant plugin install #{plugin}" unless Vagrant.has_plugin?(plugin)
end


['vagrant-vbguest'].each do |plugin|
  system "vagrant plugin install #{plugin}" unless Vagrant.has_plugin?(plugin)
end



Vagrant.configure(2) do |config|

  # Configure hostmanager plugin so nodes can be informed of each others names
  # and IP addresses (through the /etc/hosts file)
  config.hostmanager.enabled = true
  config.hostmanager.include_offline = true
  config.hostmanager.manage_host = true
  config.vm.provision :hostmanager
  # Set a custom resolver to get IP addresses - https://github.com/devopsgroup-io/vagrant-hostmanager/issues/86
  config.hostmanager.ip_resolver = proc do |vm, resolving_vm|
    if hostname = (vm.ssh_info && vm.ssh_info[:host])
      `VBoxManage guestproperty get #{vm.id} "/VirtualBox/GuestInfo/Net/1/V4/IP"`.split()[1]
    end
  end

  # Default values for nodes that will be overriden by the config files
  node_defaults = {
    :autostart => false,
    :primary => false,
    :aliases => []
  }

  # Iterate through all nodes in the node list (from the yaml file)
  config_file = YAML::load_file(File.join(File.dirname(File.expand_path(__FILE__)), 'node_config.yaml'))
  config_file.each do |node_config|

    # Merge the config from the config files with the default configs (preferring config from the files)
    node_config = node_defaults.merge(node_config)

    # Build the node
    config.vm.define node_config[:name], primary: node_config[:primary], autostart: node_config[:autostart] do |node|

      # Configure this machine (name and specs)
      node.vm.hostname = node_config[:name]
      node.vm.box = node_config[:basebox]
      # Configure this machine (network)
      node.vm.network "private_network", type: "dhcp"
      node.hostmanager.aliases = node_config[:aliases] if node_config[:aliases]

      # Configure this machine (provisioning scripts)
      node.vm.provision "shell", path: "bootstrap-scripts/#{node_config[:bootstrap]}"

      # If the node we're configuring is the puppet master (v1-pup01) then we need to mount a couple of special bits from the host
      if node_config[:name] == 'puppetmaster'
        node.vm.synced_folder '../puppetlabs', '/etc/puppet/environments/prod',
          owner:  'puppet', group: 'puppet'
        node.vm.synced_folder '../puppetlabs', '/etc/puppet/environments/qa',
          owner:  'puppet', group: 'puppet'
        node.vm.synced_folder '../misc/nodeclassifier/', '/opt/nodeclassifier',
          owner:  'puppet', group: 'puppet'
        node.vm.synced_folder './keys', '/var/lib/puppet/keys',
          owner:  'puppet', group: 'puppet'
        node.vm.synced_folder '../puppetlabs', '/etc/puppet/environments/production',
          owner:  'puppet', group: 'puppet'
        node.vm.synced_folder '../repo', '/repo',
          owner:  'root', group: 'root', mode: '0775'


      end
      node.vm.synced_folder '../packages', '/packages',
        owner:  'root', group: 'root'


      # We do not need the /vagrant folder mounted and it does in fact cause problems on Solaris hosts (https://github.com/mitchellh/vagrant/issues/7264)
      node.vm.synced_folder ".", "/vagrant", disabled: true


#      node.ssh.private_key_path = "~/.ssh/id_rsa"
      node.ssh.private_key_path = "./certs/id_rsa"


    end

  end

end

