#!/bin/bash

[ -f ./restricted/common ] && . ./restricted/common
[ -f ./restricted/host ] && . ./restricted/host

error_exit() {
    echo "ERROR DURING BUILDING IMAGE"
    exit 1
}

[ ${http_proxy} ]  && PROXY="--build-arg http_proxy=${http_proxy}"
[ ${https_proxy} ] && PROXY="${PROXY} --build-arg https_proxy=${https_proxy}"

TAG=${PANTERAS_IMAGE_TAG:-$(cat infrastructure/version)}
IMAGE=${IMAGE:-"panteras/paas-in-a-box:${TAG}"}
docker version >/dev/null 2>&1 || {
  sudo docker version >/dev/null 2>&1 && SUDO_NEEDED=1 || {
    echo "Can't run docker"
    exit 1
  }
}

[ $SUDO_NEEDED ] && SUDO='sudo'

$SUDO docker build  --rm=true ${PROXY} --tag=${REGISTRY}${IMAGE} infrastructure || error_exit
$SUDO docker tag ${REGISTRY}${IMAGE} ${IMAGE} || error_exit
