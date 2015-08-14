#!/bin/sh

[ -f ../restricted/common ] && . ../restricted/common

error_exit(){
 echo "ERROR DURING BUILDING IMAGE"
 exit 1
}

REGISTRY=${REGISTRY:-"panteras/"}
IMAGES=$(ls -l | awk '/^d/{print $NF}')
for image in $IMAGES; do
  docker build --rm=true --tag=${REGISTRY}${image} ${image}|| error_exit
  docker tag -f ${REGISTRY}${image}:latest ${image}:latest || error_exit
done
