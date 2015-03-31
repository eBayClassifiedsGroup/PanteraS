# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"
BUILD = ENV['BUILD']

if BUILD == "true"
  build = " -b"
else
  build = ""
end

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

  config.vm.provision "shell", inline: "export DOCKER_VERSION=$(awk '/ENV DOCKER_APP_VERSION/{print $3}' /vagrant/infrastructure/Dockerfile); LOCALIP=192.168.10.10 /vagrant/provision.sh -m vagrant-provision" + build
end
