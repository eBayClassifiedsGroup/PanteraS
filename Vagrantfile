# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "ubuntu/trusty64"

  config.vm.define "standalone" do |node|
    node.vm.hostname = "standalone"
    node.vm.network "private_network", ip: "192.168.10.10"
  end

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  config.vm.provider "virtualbox" do |vb|
    # Don't boot with headless mode
    #vb.gui = true
 
    # Use VBoxManage to customize the VM. For example to change memory:
    vb.customize ["modifyvm", :id, "--memory", "2048"]
  end

  # evil hack to set a proper /etc/hosts entry (non localhost) for our hostname
  config.vm.provision "shell", inline: ". /vagrant/versions.conf; export DOCKER_VERSION; LOCALIP=192.168.10.10 /vagrant/install.sh -m vagrant-provision -b"
end
