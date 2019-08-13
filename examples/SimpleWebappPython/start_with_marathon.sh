#!/bin/bash

# detect DOCKERHOST IP if was not provided
# boot2docker
[ -n "${DOCKER_HOST}" ] && IP=${IP:-$(echo $DOCKER_HOST | sed 's;.*//\(.*\):.*;\1;')}
# outside vagrant
#which vagrant && IP=${IP:-$(vagrant ssh -c ifconfig 2>/dev/null| grep -oh "\w*192.168.10.10\w*")}
# inside vagrant
[ "$HOSTNAME" == "standalone" ] && IP=${IP:-192.168.10.10}
# try to guess
IP=${IP:-$(dig +short ${HOSTNAME})}

[ -z ${IP} ] && echo "env IP variable missing" && exit 1

if [ ! -n "$1" ]
then
  echo "No arguments try to clean up previous example"
  curl -X DELETE -H "Content-Type: application/json" http://${IP}:8080/v2/apps/python-example-stable?force=true >/dev/null 2>&1
  curl -X DELETE -H "Content-Type: application/json" http://${IP}:8080/v2/apps/python-example-canaries?force=true >/dev/null 2>&1
  curl -X DELETE -H "Content-Type: application/json" http://${IP}:8080/v2/apps/python-example-tcp?force=true >/dev/null 2>&1
else
  echo "Start a new one"
  curl -X POST -H "Content-Type: application/json" http://${IP}:8080/v2/apps -d@$1
  #curl -X PUT -H "Content-Type: application/json" http://${IP}:8080/v2/apps/python-example-stable?force=true -d@$1
fi
