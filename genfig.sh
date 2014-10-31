#!/bin/bash

DC=${DC:-"UNKNOWN"}
BOOTSTRAP=${BOOTSTRAP:-" -bootstrap-expect 1"}
MODE=${MODE:-" -server"}

which boot2docker && {
  boot2docker init
  boot2docker start
  $(boot2docker shellinit)
  HOSTNAME=boot2docker
}
[ -z $DOCKER_HOST ] || IP=$(echo $DOCKER_HOST | sed 's;.*//\(.*\):.*;\1;')
IP=${IP:-$(ifconfig | awk '/inet .*10/{gsub(/.*:/,"",$2);print $2;exit}')}

eval "$(cat fig.yml.tpl| sed 's/"/+++/g'|sed  's/^\(.*\)$/echo "\1"/')"|sed 's/+++/"/g'|sed 's;\\";";g' > fig.yml
