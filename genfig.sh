#!/bin/bash

[ -f ./restricted/common ] && . ./restricted/common

DC=${DC:-"UNKNOWN"}
BOOTSTRAP=${BOOTSTRAP:-" -bootstrap-expect 1"}
MODE=${MODE:-" -server"}

B2D=""
which boot2docker && {
  boot2docker init
  boot2docker start
  $(boot2docker shellinit)
  HOSTNAME=boot2docker
  B2D="boot2docker ssh"
}

# Volumens for openvpn if needed - default no bind
OPENVPN_VOL='- "/dev/null:/dev/null"'
DNS_VOL='- "/etc/resolv.conf:/etc/resolv.conf"'

$B2D [ -d /etc/openvpn ]       2>/dev/null && OPENVPN_VOL='- "/etc/openvpn:/etc/openvpn"' && \
$B2D [ -d /etc/ssl/certs/ ]    2>/dev/null && OPENVPN_VOL=${OPENVPN_VOL}'
    - "/etc/ssl/certs/:/etc/ssl/certs/"' && \
$B2D [ -f /etc/nsswitch.conf ] 2>/dev/null && OPENVPN_VOL=${OPENVPN_VOL}'
    - "/etc/nsswitch.conf:/etc/nsswitch.conf"' && \
$B2D [ -f /etc/nslcd.conf ]    2>/dev/null && OPENVPN_VOL=${OPENVPN_VOL}'
    - "/etc/nslcd.conf:/etc/nslcd.conf"'

$B2D [ -f /etc/resolv.conf.paas ] 2>/dev/null && DNS_VOL='- "/etc/resolv.conf.paas:/etc/resolv.conf"'

[ -z $DOCKER_HOST ] || IP=$(echo $DOCKER_HOST | sed 's;.*//\(.*\):.*;\1;')
IP=${IP:-$(ifconfig | awk '/inet .*10/{gsub(/.*:/,"",$2);print $2;exit}')}

eval "$(cat fig.yml.tpl| sed 's/"/+++/g'|sed  's/^\(.*\)$/echo "\1"/')"|sed 's/+++/"/g'|sed 's;\\";";g' > fig.yml
