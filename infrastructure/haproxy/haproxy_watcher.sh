#!/bin/bash
# Script for watching HAproxy pids
# if HAproxy is not running (firt run of container)
# or is running partially then exit, so it can be respawned by supervisord
set -eu

pidfile="/tmp/haproxy.pid"
command="/usr/sbin/haproxy -f /etc/haproxy/haproxy.cfg -p ${pidfile} -sf \$(pidof /usr/bin/haproxy)"

function kill_haproxy(){
    kill $(cat $pidfile)
    exit 0
}
trap 'kill_haproxy' SIGINT SIGTERM

eval "$command"
sleep 2

while [ -f $pidfile ] && kill -0 $(cat $pidfile) ; do
    sleep 0.5
done
exit 2
