#!/bin/bash

SCRIPT=/opt/haproxy/haproxy-marathon-bridge
OUTPUT=/etc/haproxy/haproxy.cfg-marathon-bridge

while true ; do

if [ -e $SCRIPT ] ; then
 echo "$(date): regenerating haproxy config from marathon API"
 $SCRIPT $ENV_MASTER_IP:8080 > $OUTPUT
else 
 echo "$(date): cannot find script $SCRIPT"
fi

sleep 10

done

exit 1
