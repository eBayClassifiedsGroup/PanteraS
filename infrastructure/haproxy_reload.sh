#!/bin/bash

#:80/443
http=0
#:81
stats=1

DPORT=80
[ ${HAPROXY_SSL} == "true" ] && DPORT=443

haproxy_a_prefix=855
haproxy_b_prefix=866

current_state() {
   iptables -w -t nat -L HAPROXY 2>/dev/null| awk '/haproxy/{print $1}'
}

new_state() {
   old_state=$1
   if   [[ ${old_state} == "" ]]; then echo "none"
   elif [[ ${old_state} == "haproxy_a" ]]; then echo "haproxy_b"
   elif [[ ${old_state} == "haproxy_b" ]]; then echo "haproxy_a"
   else echo "unknown"
   fi
}

preconfigure() {
  iptables -w -t nat -N HAPROXY
  iptables -w -t nat -A PREROUTING -j HAPROXY
  iptables -w -t nat -A OUTPUT -j HAPROXY
  for chain in haproxy_a haproxy_b; do
    instance_prefix="${chain}_prefix"
    http_port="${!instance_prefix}${http}"
    stats_port="${!instance_prefix}${stats}"
    iptables -w -t nat -N ${chain}
    [ ${LISTEN_IP} != "0.0.0.0" ] && \
    iptables -w -t nat -A ${chain} -p tcp -d ${LISTEN_IP} --dport ${DPORT} -j DNAT --to-destination ${LISTEN_IP}:${http_port}
    iptables -w -t nat -A ${chain} -m state --state NEW -p tcp -d ${HOST_IP} --dport ${DPORT} -j REDIRECT --to ${http_port}
    iptables -w -t nat -A ${chain} -m state --state NEW -p tcp -d ${HOST_IP} --dport 81 -j REDIRECT --to ${stats_port}
    [ -n "${KEEPALIVED_VIP}" ] && {
      iptables -w -t nat -A ${chain} -m state --state NEW -p tcp -d ${KEEPALIVED_VIP} --dport ${DPORT} -j REDIRECT --to ${http_port}
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
  http_port="${!instance_prefix}${http}"
  stats_port="${!instance_prefix}${stats}"
  export PORT_STATS=${stats_port}
  export PORT_HTTP=${http_port}
  eval "$(cat /etc/haproxy/haproxy.cfg| sed 's/^\(.*\)/echo "\1"/')" >| /etc/haproxy/$1.cfg
  /usr/sbin/$1 -c -f /etc/haproxy/$1.cfg
}

# Race condition can happen also here
# but any mutex (flock/mkdir) here slows down and add additional complexity
# it doesn't matter here which one start faster,
# since we retry evey fail start
#
service_restart() {
  configure $1 || { echo "[ERROR] - configruation file is broken - leaving state as it is"; exit 0; }
  /usr/sbin/$1 -p /tmp/$1.pid -f /etc/haproxy/$1.cfg -sf $(pidof $2)
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

main() {
  [[ $1 == "cleanup" ]] && { remove; exit 0; }

  current_state=$(current_state)
  echo "Current state: ${current_state}"
  state=$(new_state $current_state)

  if [[ ${state} == "none" ]]; then
    init
  elif [[ ${state} =~ "haproxy_" ]]; then
    echo "Switching routing to ${state}"
    while ! service_restart ${state} ${current_state}; do
      echo "trying again"
    done && \
    { replace ${state} || init ; }
  else
    echo "[ERROR] unknown ipfilters state! doing cleanup and init"
    init
  fi
}
main "$@"
