#!/bin/sh

docker build --rm=true --tag=paas paas
docker build --rm=true --tag=mesos mesos
docker build --rm=true --tag=mesos-slave mesos-slave
docker build --rm=true --tag=mesos-master mesos-master
docker build --rm=true --tag=consul consul
docker build --rm=true --tag=haproxy haproxy
docker build --rm=true --tag=openvpn openvpn
docker build --rm=true --tag=registrator registrator
