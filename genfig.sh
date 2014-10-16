#!/bin/bash

BOOTSTRAP="-bootstrap-expect 1"
CONSUL_CMD="-advertise ${IP} -server -node=${HOSTNAME}"
DC="UNKNOWN"
MODE=" -server"

eval "`cat fig.yml.tpl| sed  's/^\(.*\)$/echo "\1"/'`" >fig.yml
