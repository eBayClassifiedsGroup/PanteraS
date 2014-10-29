#!/bin/bash

DC=${DC:-"UNKNOWN"}
BOOTSTRAP=${BOOTSTRAP:-" -bootstrap-expect 1"}
MODE=${MODE:-" -server"}

if [ -z "$IP" ]; then
IP=$(sudo ip addr show eth0 | perl -nle '/inet ([\d\.]+)/ && print $1')
fi

eval "$(cat fig.yml.tpl| sed 's/"/+++/g'|sed  's/^\(.*\)$/echo "\1"/')"|sed 's/+++/"/g'|sed 's;\\";";g' > fig.yml
