#!/bin/sh
PREFIX=infrastructure

docker build --rm=true --tag=paas $PREFIX/paas
docker build --rm=true --tag=mesos $PREFIX/mesos
docker build --rm=true --tag=mesos-slave $PREFIX/mesos-slave
docker build --rm=true --tag=mesos-master $PREFIX/mesos-master
docker build --rm=true --tag=consul $PREFIX/consul
docker build --rm=true --tag=haproxy $PREFIX/haproxy
docker build --rm=true --tag=openvpn $PREFIX/openvpn
docker build --rm=true --tag=registrator $PREFIX/registrator
docker build --rm=true --tag=dnsmasq $PREFIX/dnsmasq
