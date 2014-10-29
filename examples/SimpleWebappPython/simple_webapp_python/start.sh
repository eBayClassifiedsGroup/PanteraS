#!/bin/bash
unset http_proxy
unset https_proxy

HOST=${HOST:-$HOSTNAME}
NAME=${NAME:-undefined}
PORT=${PORT:-1234}

ID=$(awk -F\/ '/:cpu:/{print $3}' /proc/1/cgroup)
SCRIPT="http_proxy='' https_proxy='' wget -q -O - http://${HOST}:${PORT}/cgi-bin/index"

cd /opt/web/
/usr/bin/python3 -m http.server --cgi


