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
		echo Powering-up Ubuntu VM. may take a while. A cofee may be a good idea now...
		vagrant up
		vagrant ssh
elif [[ $unamestr == Linux && $lindistro == Ubuntu* ]]; then
        sudo apt-get -q -y install docker.io
		curl -L https://github.com/docker/fig/releases/download/1.0.0/fig-`uname -s`-`uname -m` > /tmp/fig; chmod +x /tmp/fig; sudo mv /tmp/fig /usr/local/bin
        bash build-docker-images.sh
else
        echo Only Mac OSX and Ubuntu platforms are supported. Exiting now.
        exit 1
fi

