#!/bin/bash

#:80
real=0
#:81
stats=1

haproxy_a_prefix=855
haproxy_b_prefix=866

iptables_status() {
   state=$(iptables -w -t nat -L HAPROXY 2>/dev/null| awk '/haproxy/{print $1}')
   if   [[ ${state} == "" ]]; then echo "none"
   elif [[ ${state} == "haproxy_a" ]]; then echo ${state}
   elif [[ ${state} == "haproxy_b" ]]; then echo ${state}
   else echo "unknown"
   fi
}

preconfigure() {
  iptables -w -t nat -N HAPROXY
  iptables -w -t nat -A PREROUTING -j HAPROXY
  iptables -w -t nat -A OUTPUT -j HAPROXY
  for chain in haproxy_a haproxy_b; do
    instance_prefix="${chain}_prefix"
    real_port="${!instance_prefix}${real}"
    stats_port="${!instance_prefix}${stats}"
    iptables -w -t nat -N ${chain}
    [ ${LISTEN_IP} != "0.0.0.0" ] && \
    iptables -w -t nat -A ${chain} -p tcp -d ${LISTEN_IP} --dport 80 -j DNAT --to-destination ${LISTEN_IP}:${real_port}
    iptables -w -t nat -A ${chain} -m state --state NEW -p tcp -d ${HOST_IP} --dport 80 -j REDIRECT --to ${real_port}
    iptables -w -t nat -A ${chain} -m state --state NEW -p tcp -d ${HOST_IP} --dport 81 -j REDIRECT --to ${stats_port}
    [ -n "${KEEPALIVED_VIP}" ] && {
      iptables -w -t nat -A ${chain} -m state --state NEW -p tcp -d ${KEEPALIVED_VIP} --dport 80 -j REDIRECT --to ${real_port}
      iptables -w -t nat -A ${chain} -m state --state NEW -p tcp -d ${KEEPALIVED_VIP} --dport 81 -j REDIRECT --to ${stats_port}
    }
  done
}

add() {
  chain=$1
  iptables -w -t nat -A HAPROXY -j ${chain}
}

replace() {
  chain=$1
  iptables -w -t nat -R HAPROXY 1 -j ${chain}
}

configure() {
  instance=$1
  instance_prefix="${instance}_prefix"
  real_port="${!instance_prefix}${real}"
  stats_port="${!instance_prefix}${stats}"
  export PORT_STATS=${stats_port}
  export PORT_HTTP=${real_port}
  eval "$(cat /etc/haproxy/haproxy.cfg| sed 's/^\(.*\)/echo "\1"/')" >| /etc/haproxy/$1.cfg
}

# Race condition can happen also here
# but any mutex (flock/mkdir) here slows down and add additional complexity
# it doesn't matter here which one start faster,
# since we retry evey fail start
#
service_restart() {
  configure $1 && /usr/sbin/$1 -p /tmp/$1.pid -f /etc/haproxy/$1.cfg -sf $(pidof $1) 2>/dev/null
}

remove() {
  while iptables -w -t nat -D PREROUTING -j HAPROXY > /dev/null 2>&1; do echo "remove PREROUTING HAPROXY"; done
  while iptables -w -t nat -D OUTPUT -j HAPROXY > /dev/null 2>&1; do echo "remove OUTPUT HAPROXY"; done
  for chain in HAPROXY haproxy_a haproxy_b; do
    while iptables -w -t nat -D ${chain} 1 >/dev/null 2>&1; do echo "remove ${chain}";  done
    while iptables -w -t nat -X ${chain} >/dev/null 2>&1; do echo "remove ${chain}"; done
  done
  rm -f /var/run/haproxy_a.lock /var/run/haproxy_b.lock > /dev/null 2>&1
  return 0
}

init() {
  echo "Initially routing to haproxy_a"
  remove
  preconfigure
  service_restart haproxy_a
  add haproxy_a
}

[[ $1 == "cleanup" ]] && ( remove; true ) && exit

status=$(iptables_status)
echo "Currently: ${status}"

if [[ ${status} == "none" ]]; then
  init
elif [[ ${status} == "haproxy_b" ]]; then
  echo "Switching routing to haproxy_a"
  while !(service_restart haproxy_a); do echo "trying again"; done
  replace haproxy_a || init
elif [[ ${status} == "haproxy_a" ]]; then
  echo "Switching routing to haproxy_b"
  while !(service_restart haproxy_b); do echo "trying again"; done
  replace haproxy_b || init
else
  echo "[ERROR] unknown ipfilters state! doing cleanup and init"
  init
fi
