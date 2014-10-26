#!/bin/bash

BOOTSTRAP="-bootstrap-expect 1"
CONSUL_CMD="-advertise ${IP} -server -node=${HOSTNAME}"
DC="UNKNOWN"
MODE=" -server"

eval "$(cat fig.yml.tpl| sed "s/\"/+++/g"|sed  's/^\(.*\)$/echo "\1"/')"|sed "s/+++/\"/g" > fig.yml
