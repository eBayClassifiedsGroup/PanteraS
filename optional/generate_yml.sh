#!/bin/bash

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

$B2D [ -d /etc/openvpn ]       2>/dev/null && OPENVPN_VOL='- "/etc/openvpn:/etc/openvpn"' && \
$B2D [ -d /etc/ssl/certs/ ]    2>/dev/null && OPENVPN_VOL=${OPENVPN_VOL}'
    - "/etc/ssl/certs/:/etc/ssl/certs/"' && \
$B2D [ -f /etc/nsswitch.conf ] 2>/dev/null && OPENVPN_VOL=${OPENVPN_VOL}'
    - "/etc/nsswitch.conf:/etc/nsswitch.conf"' && \
$B2D [ -f /etc/nslcd.conf ]    2>/dev/null && OPENVPN_VOL=${OPENVPN_VOL}'
    - "/etc/nslcd.conf:/etc/nslcd.conf"'


eval "$(cat docker-compose.yml.tpl| sed 's/"/+++/g'|sed  's/^\(.*\)$/echo "\1"/')"|sed 's/+++/"/g'|sed 's;\\";";g' > docker-compose.yml
