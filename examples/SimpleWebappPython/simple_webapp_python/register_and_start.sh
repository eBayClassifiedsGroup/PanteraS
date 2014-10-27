#!/bin/bash
unset http_proxy
unset https_proxy

HOST=${HOST:-$HOSTNAME}
NAME=${NAME:-undefined}
PORT=${PORT:-1234}

ID=$(awk -F\/ '/:cpu:/{print $3}' /proc/1/cgroup)
SCRIPT="http_proxy='' https_proxy='' wget -q -O - http://${HOST}:${PORT}/cgi-bin/index"
TEMPLATE=$(eval "$(cat register.tmpl| sed 's/"/+++/g'|sed 's/^\(.*\)$/echo "\1"/')" | sed 's/+++/"/g')

curl http://${HOST}:8500/v1/agent/service/deregister/${ID}
curl -X PUT  -d "${TEMPLATE}" http://${HOST}:8500/v1/agent/service/register

cd /opt/web/
/usr/bin/python3 -m http.server --cgi


