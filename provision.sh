#!/bin/bash

paas="PanteraS"
REPODIR=`dirname $0`
IMAGE="panteras/paas-in-a-box:latest"

usage(){
cat <<_END_

Summary:
    Provision $paas on either vagrant vm or a boot2docker vm.

Options
    -m boot2docker|docker-machine|vagrant|vagrant-provision
    -h help
    -b rebuild $paas image

Examples

    Provision $paas for use with docker-machine:

        $0 -m docker-machine

    Provision $paas for use with boot2docker:

        $0 -m boot2docker

    Provision $paas for use with vagrant:

        $0 -m vagrant

    Provision $paas components inside the vagrant virtual machine

        $0 -m vagrant-provision -b

_END_
}

MODE=""
BUILDIMAGES=false

while getopts ":m:bh" mode ; do
  case $mode in
  m)
    case $OPTARG in
    boot2docker|docker-machine|vagrant|vagrant-provision)
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
    ;;
esac
done

[ -z "$MODE" ] && {
  echo "missing mode" >&2
  usage 1>&2
  exit 1
}

# tests
isMac()    { [[ "$OSTYPE" == "darwin"* ]] && return 0 || return 1; }
isLinux()  { [[ "$OSTYPE" == "linux"* ]] && return 0 || return 1; }
isUbuntu() { uname -a |grep -i ubuntu &>/dev/null && return 0 || return 1; }

hasVagrant()       { $(hash vagrant 2>/dev/null) && return 0 || return 1; }
hasVirtualBox()    { $(hash VBoxManage 2>/dev/null) && return 0 || return 1; }
hasDockerCompose() { $(hash docker-compose 2>/dev/null) && return 0 || return 1; }
hasBoot2docker()   { $(hash boot2docker 2>/dev/null) && return 0 || return 1; }
hasDocker()        { $(hash docker 2>/dev/null) && return 0 || return 1; }
hasDockerMachine() { $(hash docker-machine 2>/dev/null) && return 0 || return 1; }

case "$MODE" in
'vagrant')
  hasVagrant || { echo "Vagrant not detected." >&2 && exit 1; }
  hasVirtualBox || { echo "VirtualBox not detected." >&2 && exit 1; }
  [ ! -f Vagrantfile ] && \
    echo "Cannot find Vagrantfile. Are you running this from inside $paas git-repo top-level directory?" >&2 && \
    exit 1
  echo "starting vagrant vm with provisioning ..."
  vagrant reload --provision
  ;;

'vagrant-provision')
  echo "provisioning vagrant virtual machine with $paas components"
  ! isUbuntu && echo "error: $paas is only supported on an Ubuntu virtual machine host" && exit 1

  [ ! -f /etc/apt/sources.list.d/docker.list ] && {
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv F76221572C52609D
    echo 'deb https://apt.dockerproject.org/repo ubuntu-trusty main' > /etc/apt/sources.list.d/docker.list
    sudo apt-get update
  }

  # ensure that "aufs" will be used within vagrant; see: https://forums.docker.com/t/docker-1-7-0-is-using-huge-amount-of-disk-space/2046
  sudo apt-get -q -y install linux-image-extra-$(uname -r)
  sudo apt-get -q -y install docker-engine=${DOCKER_VERSION} \
    || { wget http://apt.dockerproject.org/repo/pool/main/d/docker-engine/docker-engine_${DOCKER_VERSION}_amd64.deb \
    && dpkg -i docker-engine_${DOCKER_VERSION}_amd64.deb; }


  ! hasDockerCompose && {
    sudo apt-get install -y python-pip
    # Fix for pip - Ubuntu provide incompatible version
    sudo pip install pip --upgrade
    sudo pip install docker-compose --upgrade
  }
  # verify:
  ! hasDocker && echo "error: docker not detected." >&2 && exit 1
  ! hasDockerCompose && echo "error: docker-compose not detected" >&2 && exit 1
  echo BUILDIMAGES
  echo $BUILDIMAGES
  [ "$BUILDIMAGES" == "true" ] && cd $REPODIR && sudo ./build-docker-images.sh \
    || docker pull ${IMAGE}

  LOCALIP=${LOCALIP:-$(hostname --ip-address| awk '{ print $2}')}
  DNS_CONFIG="DOCKER_OPTS=\"\${DOCKER_OPTS} --dns $LOCALIP\""
  grep -q -- "$DNS_CONFIG" /etc/default/docker || echo $DNS_CONFIG >>/etc/default/docker && sudo service docker restart

  # evil hack to set a proper /etc/hosts entry (non localhost) for our hostname.
  #   This is needed for marathon (and posible consul) checks to work properly. Since these
  #   service run within a docker container, and checks are performed on <MESOS_SLAVE_HOSTNAME>:<PORT>,
  #   this must resolve to a non localhost IP.
  sudo sed -i "s/^127\.0\.1\.1\(.*\)/$LOCALIP\1/" /etc/hosts

  cd $REPODIR
  echo "stopping any running docker containers."
  sudo docker-compose stop 2>/dev/null
  sudo docker-compose kill 2>/dev/null
  echo "deleting previously run docker containers."
  sudo docker-compose rm --force 2>/dev/null

  echo "(re)generating configuration file"
  IP=$LOCALIP ./generate_yml.sh
  echo "starting $paas components with docker-compose"
  sudo docker-compose up -d
  ;;


"boot2docker"|"docker-machine")
  ! isMac && echo "boot2docker/docker-machine is only supported on OSX" >&2 && exit 1
  ! hasDockerCompose && echo "DockerCompose not found. Please install docker-compose" >&2 && exit 1

  [ "$MODE" = "boot2docker" ] && {
    ! hasBoot2docker ] && echo "boot2docker not found. Please install the latest boot2docker version on your Mac" >&2 && exit 1

    [ "$(boot2docker status 2>/dev/null)" != "running" ] && {
      echo "boot2docker not running. Attempting to start."
      boot2docker up
    } || {
      echo "boot2docker is already running. not starting boot2docker."
    }
    $(boot2docker shellinit)

    DOCKERHOST_IP=$(boot2docker ip 2>/dev/null)
    SSH_COMMAND="boot2docker ssh"

  }

  [ "$MODE" = "docker-machine" ] && {
    ! hasDockerMachine ] && echo "docker-machine not found. Please install the latest docker-machine version on your Mac" >&2 && exit 1
    ! DOCKER_MACHINE_NAME=$(docker-machine active 2>/dev/null) && echo "no active docker-machine, please run eval eval \$(docker-machine env NAME)" >&2 && exit 1

    echo "Using docker-machine \"$DOCKER_MACHINE_NAME\""
    DOCKERHOST_IP=$(docker-machine ip $DOCKER_MACHINE_NAME 2>/dev/null)
    SSH_COMMAND="docker-machine ssh $DOCKER_MACHINE_NAME"

  }

  [ "$BUILDIMAGES" == "true" ] && cd $REPODIR && ./build-docker-images.sh \
    || docker pull ${IMAGE}


  # dns config on boot2docker
  DNS_CONFIG="EXTRA_ARGS=\\\"\\\${EXTRA_ARGS} --dns $DOCKERHOST_IP\\\""
  $SSH_COMMAND \
    "sudo touch /var/lib/boot2docker/profile && \
     grep -q -- \"$DNS_CONFIG\" /var/lib/boot2docker/profile || { \
       echo $DNS_CONFIG | \
       sudo tee -a /var/lib/boot2docker/profile && \
       sudo /etc/init.d/docker restart && \
       sleep 4
     }"

  echo "(re)generating docker-compose.yml configuration file"
  cd $REPODIR
  echo "generating docker-compose.yml configuration with boot2docker host ip $DOCKERHOST_IP"
  IP=$DOCKERHOST_IP ./generate_yml.sh
  echo "clean up previous container"
  docker-compose stop 2>/dev/null
  docker-compose kill 2>/dev/null
  docker-compose rm --force 2>/dev/null
  echo "starting $paas container"
  docker-compose up -d
  ;;

*)
  echo "wrong match" >&2
  exit 1
  ;;
esac
# close boot2docker mode

exit 0
