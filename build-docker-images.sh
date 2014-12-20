#!/bin/sh
PREFIX=infrastructure

myexit(){
 echo "ERROR DURING BUILDING IMAGE"
 exit 1
}

docker build --rm=true --tag=paas $PREFIX/paas || myexit
docker build --rm=true --tag=mesos $PREFIX/mesos || myexit
docker build --rm=true --tag=mesos-slave $PREFIX/mesos-slave || myexit
docker build --rm=true --tag=mesos-master $PREFIX/mesos-master || myexit
docker build --rm=true --tag=consul $PREFIX/consul || myexit
docker build --rm=true --tag=haproxy $PREFIX/haproxy || myexit
docker build --rm=true --tag=openvpn $PREFIX/openvpn
docker build --rm=true --tag=registrator $PREFIX/registrator || myexit
docker build --rm=true --tag=dnsmasq $PREFIX/dnsmasq || myexit
