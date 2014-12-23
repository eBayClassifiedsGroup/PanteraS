#!/bin/bash

VAGRANT_OSX_URL=https://dl.bintray.com/mitchellh/vagrant/vagrant_1.6.5.dmg
VIRTUALBOX_OSX_URL=http://download.virtualbox.org/virtualbox/4.3.18/VirtualBox-4.3.18-96516-OSX.dmg
VAGRANT_INSTALL_FILE=${VAGRANT_OSX_URL##*/}
VIRTUAL_BOX_INSTALL_FILE=${VIRTUALBOX_OSX_URL##*/}
FIG_URL=https://github.com/docker/fig/releases/download/1.0.1/fig-`uname -s`-`uname -m`
unamestr=`uname`
lindistro=`cat /etc/issue 2>/dev/null`
paas="Paas-in-a-box"
FIG_INSTALL_PATH=/usr/local/bin/fig
REPODIR=`dirname $0`

usage(){
cat <<_END_

Summary:
    Install necessary components for $paas.  Installs $paas on either vagrant vm or a boot2docker vm.

Options
    -m boot2docker|vagrant|vagrant-provision
    -h help
    -b remove and rebuild all docker images

Examples

    Install $paas for use with boot2docker:

	$0 -m boot2docker

    Install $paas for use with vagrant:

	$0 -m vagrant

    Install $paas components inside the vagrant virtual machine

	$0 -m vagrant-provision -b

_END_
}

MODE=""
BUILDIMAGES=false

while getopts ":m:bh" mode ; do 
      case $mode in
	m)
	    case $OPTARG in
		boot2docker|vagrant|vagrant-provision)
		    echo "installing with mode \"$OPTARG\""
		    MODE=$OPTARG
		;;
		*)
		    echo "invalid argument for \"$OPTARG\" for option -m" >&2
		    usage >&2
		    exit 1
		;;
	    esac
	    ;;
        vagrant)
	    echo "vagrant"
	    ;;
        \?)
	    echo "invalid option"
	    ;;
	b)
	    BUILDIMAGES=true
	    ;;
	h)
	    usage >&2
	    exit 0
	    ;;
	:)
	    echo "Error: missing argument for -$OPTARG" >&2
	    usage >&2
	    exit 1
	    
	esac
done

if [ -z "$MODE" ] ; then
    echo "missing mode" >&2
    usage 1>&2
    exit 1
fi

# tests
isMac() {
[[ "$OSTYPE" == "darwin"* ]] && return 0 || return 1
}

isLinux() {
[[ "$OSTYPE" == "linux"* ]] && return 0 || return 1
}


isUbuntu() {
    uname -a |grep -i ubuntu &>/dev/null && return 0 || return 1
}

hasVagrant() {
$(hash vagrant 2>/dev/null) && return 0 || return 1
}

hasVirtualBox() {
$(hash VBoxManage 2>/dev/null) && return 0 || return 1
}

hasFig() {
$(hash fig 2>/dev/null) && return 0 || return 1
}

hasBoot2docker() {
$(hash boot2docker 2>/dev/null) && return 0 || return 1
}

hasCurl() {
$(hash curl 2>/dev/null) && return 0 || return 1
}

hasDocker() {
$(hash docker 2>/dev/null) && return 0 || return 1
}

if ! hasCurl ; then
    echo "error: this script requires curl.  Please install curl." >&2
    exit 1
fi

if [ "$MODE" == "vagrant" ] ; then

    MISSING_REQS=false
    if isLinux ; then
        if ! hasVagrant ; then
	    echo "Error: Please install Vagrant for your Linux distribution" >&2
	    MISSING_REQS=true
        fi

        if ! hasVirtualBox ; then
	    echo "Error: Please install VirtualBox for your Linux distribution" >&2
	    MISSING_REQS=true
        fi
    fi

    if [ "$MISSING_REQS" == "true" ] ; then
	exit 1
    fi

    if isMac ; then
	if ! hasVagrant ; then
	    echo "installing vagrant version $VAGRANT_INSTALL_FILE"
	    curl -L -O $VAGRANT_OSX_URL
	    hdiutil mount $VAGRANT_INSTALL_FILE
	    sudo installer -verbose -pkg /Volumes/Vagrant/Vagrant.pkg -target /
	    hdiutil unmount /Volumes/Vagrant
	    test -f $VAGRANT_INSTALL_FILE && rm $VAGRANT_INSTALL_FILE
        else
	    echo "vagrant installation detected. skipping install step."
        fi

	if ! hasVirtualBox ; then
	    echo "installing VirtualBox"
	    curl -L -O $VIRTUALBOX_OSX_URL
	    hdiutil mount $VIRTUAL_BOX_INSTALL_FILE
	    sudo installer -verbose -pkg /Volumes/VirtualBox/VirtualBox.pkg -target /
	    hdiutil unmount /Volumes/VirtualBox
	    test -f $VIRTUAL_BOX_INSTALL_FILE && rm $VIRTUAL_BOX_INSTALL_FILE
	else
	    echo "VirtualBox installation detected. skipping install step."
        fi
    fi # close mac section

    if ! hasVagrant ; then
	echo "vagrant installation not detected.  Check installation steps or install vagrant manually" >&2
	exit 1
    fi

    if ! hasVirtualBox ; then
	echo "VirtualBox installation not detected.  Check installation steps or install VirtualBox manually" >&2
	exit 1
    fi

    if [ -f Vagrantfile ] ; then
	echo "starting vagrant vm with provisioning ..."
	vagrant reload --provision
    else
	echo "cannot find Vagrantfile.  are you running this from inside $pass git-repo top-level directory?" >&2
	exit 1
    fi


fi # close vagrant installation mode

if [ "$MODE" == "vagrant-provision" ] ; then

    echo "provisioning vagrant virtual machine with $paas components"

    if ! isUbuntu ; then
	echo "error: $paas is only supported on an Ubuntu virtual machine host"
	exit 1
    fi

    if [ ! -f /etc/apt/sources.list.d/docker.list ]; then
	sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
	echo 'deb http://get.docker.io/ubuntu docker main' > /tmp/docker.list
	sudo mv /tmp/docker.list /etc/apt/sources.list.d/
	sudo apt-get update
    fi

    sudo apt-get -q -y install lxc-docker-${DOCKER_VERSION}

    if ! hasFig; then
       curl -L $FIG_URL > /tmp/fig; chmod +x /tmp/fig; sudo mv /tmp/fig /usr/local/bin
       #sudo apt-get install python-pip
       #sudo pip install fig
    fi

    # verify docker installation
    if ! hasDocker ; then
	echo "error: aborting. docker installation not detected. Check the docker installation steps for any errors." >&2
	exit 1
    fi

    # verify fig installation
    if ! hasFig ; then
	echo "error: aborting. fig installation not detected. Check the fig installation steps for any errors." >&2
	exit 1
    fi

    if [ "$BUILDIMAGES" == "true" ] ; then
	echo "deleting all docker images."
	sudo docker rmi -f $(sudo docker images -q) 2>/dev/null

	echo "building docker images. This will take some time"
	cd $REPODIR
	sudo ./build-docker-images.sh
    fi

    LOCALIP=${LOCALIP:-$(hostname --ip-address| awk '{ print $2}')}
    DNS_CONFIG="DOCKER_OPTS=\"\${DOCKER_OPTS} --dns $LOCALIP\""
    grep -q -- "$DNS_CONFIG" /etc/default/docker || echo $DNS_CONFIG >>/etc/default/docker

    echo "stopping any running docker containers."
    sudo docker stop $(sudo docker ps -a -q) 2>/dev/null
    echo "deleting previously run docker containers."
    sudo docker rm $(sudo docker ps -a -q) 2>/dev/null

    echo "(re)generating fig.yml configuration file"
    cd $REPODIR
    IP=$LOCALIP ./genfig.sh
    echo "starting $paas components with fig"
    sudo fig up -d

fi # close vagrant-provision mode

if [ "$MODE" == "boot2docker" ] ; then

    if ! isMac ; then
	echo "boot2docker is only supported on OSX" >&2
	exit 1
    fi

    if ! hasBoot2docker ; then
	echo "boot2docker not found. Please install the latest boot2docker version on your Mac" >&2
	exit 1
    fi

    if ! hasFig ; then
	echo "fig not found. Installing fig" >&2
	echo "sudo will be used to install fig in $FIG_INSTALL_PATH"
        curl -L $FIG_URL > /tmp/fig
	sudo mv /tmp/fig $FIG_INSTALL_PATH
	sudo chmod +x $FIG_INSTALL_PATH
    fi

    # verify fig installation
    if ! hasFig ; then
	echo "fig could not be installed. Please check the fig installation steps for errors or install fig manually, then rerun this script." >&2
	exit 1
    fi

    if [ "$(boot2docker status 2>/dev/null)" != "running" ] ; then
	echo "boot2docker not running. Attempting to start."	
	boot2docker up
    else
	echo "boot2docker is already running. not starting boot2docker."
    fi 

    $(boot2docker shellinit)

    echo "stopping any running docker containers."
    docker stop $(docker ps -a -q) 2>/dev/null
    echo "deleting previously run docker containers."
    docker rm $(docker ps -a -q) 2>/dev/null

    if [ "$BUILDIMAGES" == "true" ] ; then
	echo "deleting all docker images."
	docker rmi -f $(docker images -q) 2>/dev/null

	echo "building docker images. This will take some time"
	cd $REPODIR
	./build-docker-images.sh
    fi

    BOOT2DOCKERIP=$(boot2docker ip 2>/dev/null)
    # dns config on boot2docker
    
    DNS_CONFIG="EXTRA_ARGS=\\\"\\\${EXTRA_ARGS} --dns $BOOT2DOCKERIP\\\""
    boot2docker ssh \
      "sudo touch /var/lib/boot2docker/profile && \
       grep -q -- \"$DNS_CONFIG\" /var/lib/boot2docker/profile || { \
         echo $DNS_CONFIG | \
         sudo tee -a /var/lib/boot2docker/profile && \
         sudo /etc/init.d/docker restart && \
         sleep 4
       }"


    echo "(re)generating fig.yml configuration file"
    cd $REPODIR
    echo "generating fig.yml configuration with boot2docker host ip $BOOT2DOCKERIP"
    IP=$BOOT2DOCKERIP ./genfig.sh
    echo "stopping any previously running containers with fig."
    $FIG_INSTALL_PATH stop
    echo "starting $paas components with fig"
    $FIG_INSTALL_PATH up -d

fi # close boot2docker mode

exit 0
