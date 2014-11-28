#!/bin/bash
while true;
do
  sleep 1 && envconsul -reload=true consul /bin/sh -c '[ -z \${WAN_HOSTS} ] || consul join -wan \${WAN_HOSTS}; sleep 63072000'
done
