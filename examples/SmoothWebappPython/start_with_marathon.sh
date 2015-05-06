#!/bin/bash
[ -z $DOCKER_HOST ] || IP=$(echo $DOCKER_HOST | sed 's;.*//\(.*\):.*;\1;')
IP=${IP:-$(ifconfig | awk '/inet .*10/{gsub(/.*:/,"",$2);print $2;exit}')}

if [ ! -n "$1" ]
then
  echo "No arguments try to clean up previous example"
  curl -X DELETE -H "Content-Type: application/json" http://${IP}:8080/v2/apps/python-smooth-stable?force=true >/dev/null 2>&1
  curl -X DELETE -H "Content-Type: application/json" http://${IP}:8080/v2/apps/python-smooth-canaries?force=true >/dev/null 2>&1
else
  echo "Start a new one"
  curl -X POST -H "Content-Type: application/json" http://${IP}:8080/v2/apps/ -d@$1
fi
