#!/bin/sh

[ -f ./restricted/common ] && . ./restricted/common
[ -f ./restricted/common ] && . ./restricted/host

error_exit() {
    echo "ERROR DURING BUILDING IMAGE"
    exit 1
}

TAG=${TAG:-"latest"}
IMAGE=${IMAGE:-"panteras/paas-in-a-box:${TAG}"}

docker build --rm=true --tag=${REGISTRY}${IMAGE} infrastructure || error_exit
docker tag             -f    ${REGISTRY}${IMAGE} ${IMAGE}       || error_exit
