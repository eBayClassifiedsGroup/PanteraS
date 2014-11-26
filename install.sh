#!/bin/bash

unamestr=`uname`
lindistro=`cat /etc/issue`
if [[ $unamestr == Darwin ]]; then
	#install vagrant
	VAGRANT_VER=1.6.5
	echo Installing Vagrant v${VAGRANT_VER}...
	curl -L -O https://dl.bintray.com/mitchellh/vagrant/vagrant_${VAGRANT_VER}.dmg
	hdiutil mount vagrant_${VAGRANT_VER}.dmg
	sudo installer -verbose -pkg /Volumes/Vagrant/Vagrant.pkg -target /
	hdiutil unmount /Volumes/Vagrant

	echo installing VirtualBox...
	#install VirtualBox
	curl -L -O http://download.virtualbox.org/virtualbox/4.3.18/VirtualBox-4.3.18-96516-OSX.dmg
	hdiutil mount VirtualBox-4.3.18-96516-OSX.dmg
	sudo installer -verbose -pkg /Volumes/VirtualBox/VirtualBox.pkg -target /
	hdiutil unmount /Volumes/VirtualBox

	#cleanup
	rm *.dmg
	#fire-up an Ubuntu VM via vagrant. The
	echo Installing VM. It may take a while. A cofee may be a good idea now...
	vagrant up
	echo Done. Now run: vagrant ssh
elif [[ $unamestr == Linux && $lindistro == Ubuntu* ]]; then
	MYDIR=`dirname $0`
	LOCALIP=${LOCALIP:-$(hostname --ip-address)}

	if [ ! -f /etc/apt/sources.list.d/docker.list ]; then
		sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
		echo 'deb http://get.docker.io/ubuntu docker main' > /tmp/docker.list
		sudo mv /tmp/docker.list /etc/apt/sources.list.d/
		sudo apt-get update
	fi
	sudo apt-get -q -y install lxc-docker

	if [ ! -f /usr/local/bin/fig ]; then
		curl -L https://github.com/docker/fig/releases/download/1.0.0/fig-`uname -s`-`uname -m` > /tmp/fig; chmod +x /tmp/fig; sudo mv /tmp/fig /usr/local/bin
	fi

	which docker || { echo "docker command not in path (install failed? check previous output), killing myself"; exit 1; }

	sudo docker stop $(sudo docker ps -a -q)
	sudo docker stop $(sudo docker ps -a -q)
	sudo docker rm $(sudo docker ps -a -q)
	sudo docker rmi -f $(sudo docker images -q)
	echo Installing docker images. It may take a while. A cofee may be a good idea now...
	cd $MYDIR
	sudo ./build-docker-images.sh

	IP=$LOCALIP ./genfig.sh
	sudo fig up -d
	echo Done. Now run: sudo docker run -i -t paas
else
	echo Only Mac OSX and Ubuntu platforms are supported. Exiting now.
	exit 1
fi

