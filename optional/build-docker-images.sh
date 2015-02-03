#!/bin/sh

[ -f ../restricted/common ] && . ../restricted/common
PREFIX=.

myexit(){
 echo "ERROR DURING BUILDING IMAGE"
 exit 1
}

IMAGES="openvpn"
for image in $IMAGES; do
  docker build --rm=true --tag=${REGISTRY}${image} $PREFIX/${image}|| myexit
  docker tag -f ${REGISTRY}${image}:latest ${image}:latest || myexit
done
