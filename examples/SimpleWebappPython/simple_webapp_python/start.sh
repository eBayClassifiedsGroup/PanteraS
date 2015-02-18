#!/bin/bash

PORT_INT=8000
MASTER_HOST=${HOST}

CONTAINER_ID=${HOSTNAME}
CONTAINER_NAME=$(docker inspect -format="{{ .Name }}" ${CONTAINER_ID}|awk -F/ '{print $2}')

CONSUL_MASTER="consul.service.consul"
CONSUL_SERVICE_NAME="${MASTER_HOST}-registrator:${CONTAINER_NAME}:${PORT_INT}"

DEREGISTER="curl http://${CONSUL_MASTER}:8500/v1/agent/service/deregister/${CONSUL_SERVICE_NAME}"

trap '$DEREGISTER && sleep 2 && kill -TERM $PID' TERM INT

cd /opt/web/
/usr/bin/python3 -m http.server --cgi &
PID=$!
wait $PID
trap - TERM INT
wait $PID
EXIT_STATUS=$?



