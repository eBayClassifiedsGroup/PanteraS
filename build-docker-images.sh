#!/bin/bash

[ -f ./restricted/common ] && . ./restricted/common
[ -f ./restricted/host ] && . ./restricted/host

error_exit() {
    echo "ERROR DURING BUILDING IMAGE"
    exit 1
}

TAG=${PANTERAS_IMAGE_TAG:-$(awk '{print $2}' infrastructure/version)}
IMAGE=${IMAGE:-"panteras/paas-in-a-box:${TAG}"}
docker version >/dev/null 2>&1 || { 
  sudo docker version >/dev/null 2>&1 && SUDO_NEEDED=1 || {
    echo "Can't run docker"
    exit 1
  }
}

[ $SUDO_NEEDED ] && SUDO='sudo'

$SUDO docker build --rm=true --tag=${REGISTRY}${IMAGE} infrastructure || error_exit
$SUDO docker tag                   ${REGISTRY}${IMAGE} ${IMAGE}       || error_exit
