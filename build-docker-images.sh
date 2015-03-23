#!/bin/sh

[ -f ./restricted/common ] && . ./restricted/common
[ -f ./restricted/common ] && . ./restricted/host

myexit(){
 echo "ERROR DURING BUILDING IMAGE"
 exit 1
}
image=panteras
docker build --rm=true --tag=${REGISTRY}${image} infrastructure|| myexit
docker tag -f ${REGISTRY}${image}:latest ${image}:latest || myexit
