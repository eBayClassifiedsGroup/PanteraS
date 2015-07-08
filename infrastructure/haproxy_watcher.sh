#!/bin/bash
# Script for watching HAproxy pids
# if HAproxy is not running (firt run of container)
# or is running partially then exit, so it can be respawned by supervisord
set -eu

pidfile="/tmp/haproxy.pid"

iptables -n -t mangle -L OUTPUT | grep -E "$HOST_IP.*dpt:80" || {
  iptables -t mangle -I OUTPUT -p tcp -s $HOST_IP --dport 80  --syn -j MARK --set-mark 1
}

nl-qdisc-list | grep -q "dev lo id 1: parent root bands 4" || {
  # Set up the queuing discipline
  tc qdisc add dev lo root handle 1: prio bands 4
  tc qdisc add dev lo parent 1:1 handle 10: pfifo limit 1000
  tc qdisc add dev lo parent 1:2 handle 20: pfifo limit 1000
  tc qdisc add dev lo parent 1:3 handle 30: pfifo limit 1000

  # Create a plug qdisc with 1 meg of buffer
  nl-qdisc-add --dev=lo --parent=1:4 --id=40: plug --limit 1048576
  # Release the plug
  nl-qdisc-add --dev=lo --parent=1:4 --id=40: --update plug --release-indefinite

  # Set up the filter, any packet marked with “1” will be
  # directed to the plug
  tc filter add dev lo protocol ip parent 1:0 prio 1 handle 1 fw classid 1:4
}

function kill_haproxy(){
    kill $(cat $pidfile)
    exit 0
}
trap 'kill_haproxy' SIGINT SIGTERM

/opt/consul-template/haproxy_reload.sh
sleep 2

while [ -f $pidfile ] && kill -0 $(cat $pidfile) ; do
    sleep 0.5
done
exit 2
