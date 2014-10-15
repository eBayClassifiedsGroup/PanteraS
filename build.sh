#!/bin/sh
docker build --rm=true --tag=mesos mesos
docker build --rm=true --tag=mesos-slave mesos-slave
docker build --rm=true --tag=mesos-master mesos-master
