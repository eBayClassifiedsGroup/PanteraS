#!/bin/bash

[ -f ./restricted/common ] && . ./restricted/common
[ -f ./restricted/host ]   && . ./restricted/host

DC=${DC:-"UNKNOWN"}
BOOTSTRAP=${BOOTSTRAP:-" -bootstrap-expect 1"}
MODE=${MODE:-" -server"}
CLUSTER_NAME=${CLUSTER_NAME:-"mesoscluster"}
ZOOKEEPER_HOSTS=${ZOOKEEPER_HOSTS:-"${HOSTNAME}:2181"}


B2D=""
which boot2docker && {
  boot2docker init
  boot2docker start
  $(boot2docker shellinit)
  HOSTNAME=boot2docker
  B2D="boot2docker ssh"
}

DNS_VOL='- "/etc/resolv.conf:/etc/resolv.conf"'
$B2D [ -f /etc/resolv.conf.paas ] 2>/dev/null && DNS_VOL='- "/etc/resolv.conf.paas:/etc/resolv.conf"'

[ -z $DOCKER_HOST ] || IP=$(echo $DOCKER_HOST | sed 's;.*//\(.*\):.*;\1;')
IP=${IP:-$(ifconfig | awk '/inet .*10/{gsub(/.*:/,"",$2);print $2;exit}')}

eval "$(cat fig.yml.tpl| sed 's/"/+++/g'|sed  's/^\(.*\)$/echo "\1"/')"|sed 's/+++/"/g'|sed 's;\\";";g' > fig.yml
