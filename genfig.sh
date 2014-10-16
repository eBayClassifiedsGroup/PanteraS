#!/bin/sh

CONSUL_CMD="-bootstrap-expect 1 -advertise ${IP} -server -node=${HOSTNAME} -dc=UNKNOWN"

eval "`cat fig.yml.tpl| sed  's/^\(.*\)$/echo "\1"/'`" >fig.yml
