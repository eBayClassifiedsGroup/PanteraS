#!/bin/sh

[ -f ../restricted/common ] && . ../restricted/common

myexit(){
 echo "ERROR DURING BUILDING IMAGE"
 exit 1
}

IMAGES="java7 java8"
for image in $IMAGES; do
  docker build --rm=true --tag=${REGISTRY}${image} ${image}|| myexit
  docker tag -f ${REGISTRY}${image}:latest ${image}:latest || myexit
done
