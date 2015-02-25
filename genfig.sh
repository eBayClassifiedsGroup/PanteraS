#!/bin/bash

[ -f ./restricted/common ]    && . ./restricted/common
[ -f ./restricted/host ]      && . ./restricted/host
[ -f ./restricted/overwrite ] && . ./restricted/overwrite

[ -z $DOCKER_HOST ] || IP=$(echo $DOCKER_HOST | sed 's;.*//\(.*\):.*;\1;')
IP=${IP:-$(ifconfig | awk '/inet .*10/{gsub(/.*:/,"",$2);print $2;exit}')}


CONSUL_IP=${IP}
CONSUL_DC=${CONSUL_DC:-"UNKNOWN"}
CONSUL_BOOTSTRAP=${CONSUL_BOOTSTRAP:-'" -bootstrap-expect 1"'}
CONSUL_MODE=${CONSUL_MODE:-'" -server"'}
MESOS_CLUSTER_NAME=${CLUSTER_NAME:-"mesoscluster"}


B2D=""
which boot2docker && {
  boot2docker init
  boot2docker start
  $(boot2docker shellinit)
  HOSTNAME=boot2docker
  B2D="boot2docker ssh"
}

ZOOKEEPER_HOSTS=${ZOOKEEPER_HOSTS:-"${HOSTNAME}:2181"}

DNS_VOL='- "/etc/resolv.conf:/etc/resolv.conf"'
$B2D [ -f /etc/resolv.conf.paas ] 2>/dev/null && DNS_VOL='- "/etc/resolv.conf.paas:/etc/resolv.conf"'


eval "$(cat fig.yml.tpl| sed 's/"/+++/g'|sed  's/^\(.*\)$/echo "\1"/')"|sed 's/+++/"/g'|sed 's;\\";";g' > fig.yml
