#!/bin/sh

[ -f ./restricted/common ] && . ./restricted/common
PREFIX=infrastructure

myexit(){
 echo "ERROR DURING BUILDING IMAGE"
 exit 1
}

docker build --rm=true --tag=${REPOSITORY}paas $PREFIX/paas || myexit
docker build --rm=true --tag=${REPOSITORY}mesos $PREFIX/mesos || myexit
docker build --rm=true --tag=${REPOSITORY}mesos-slave $PREFIX/mesos-slave || myexit
docker build --rm=true --tag=${REPOSITORY}mesos-master $PREFIX/mesos-master || myexit
docker build --rm=true --tag=${REPOSITORY}consul $PREFIX/consul || myexit
docker build --rm=true --tag=${REPOSITORY}haproxy $PREFIX/haproxy || myexit
docker build --rm=true --tag=${REPOSITORY}openvpn $PREFIX/openvpn
docker build --rm=true --tag=${REPOSITORY}registrator $PREFIX/registrator || myexit
docker build --rm=true --tag=${REPOSITORY}dnsmasq $PREFIX/dnsmasq || myexit
