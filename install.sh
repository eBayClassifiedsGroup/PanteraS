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
	cd vagrant
	echo Installing VM. It may take a while. A cofee may be a good idea now...
	vagrant up
	@echo Done. Now run: vagrant ssh
elif [[ $unamestr == Linux && $lindistro == Ubuntu* ]]; then
	LOCALIP=`hostname --ip-address`
	sudo apt-get -q -y install docker.io
	curl -L https://github.com/docker/fig/releases/download/1.0.0/fig-`uname -s`-`uname -m` > /tmp/fig; chmod +x /tmp/fig; sudo mv /tmp/fig /usr/local/bin
	sudo docker stop $(sudo docker ps -a -q)
	sudo docker stop $(sudo docker ps -a -q)
	sudo docker rm $(sudo docker ps -a -q)
	sudo docker rmi -f $(sudo docker images -q)
	echo Installing VMs. It may take a while. A cofee may be a good idea now...
	sudo docker build --rm=true --tag=paas paas
	sudo docker build --rm=true --tag=mesos mesos
	sudo docker build --rm=true --tag=mesos-slave mesos-slave
	sudo docker build --rm=true --tag=mesos-master mesos-master
	sudo docker build --rm=true --tag=consul consul
	sudo docker build --rm=true --tag=haproxy haproxy
	HOSTNAME=boot2docker IP=$LOCALIP ./genfig.sh
	sudo fig up -d
	echo Done. Now run: sudo docker run -i -t paas
else
	echo Only Mac OSX and Ubuntu platforms are supported. Exiting now.
	exit 1
fi

# for all operating systems
	sudo docker pull progrium/registrator
