#!/bin/bash
unset http_proxy
unset https_proxy

ID=$(awk -F\/ '/:cpu:/{print $3}' /proc/1/cgroup)
TEMPLATE=$(eval "$(cat register.tmpl| sed 's/"/+++/g'|sed 's/^\(.*\)$/echo "\1"/')" | sed 's/+++/"/g')

curl http://$HOSTNAME:8500/v1/agent/service/deregister/$ID
curl -X PUT  -d "${TEMPLATE}" http://$HOSTNAME:8500/v1/agent/service/register

cd /opt/web/
/usr/bin/python3 -m http.server --cgi


