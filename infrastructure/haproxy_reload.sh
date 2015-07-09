#!/bin/bash

num_rules=2
real=0
stats=1

a_prefix=855
b_prefix=866

iptables_status() {
   a=$(iptables -t nat -L -n -v | grep -c REDIRECT.*${a_prefix})
   b=$(iptables -t nat -L -n -v | grep -c REDIRECT.*${b_prefix})

   if   [[ ${a} == 0 && ${b} == 0 ]]; then echo "none"
   elif [[ ${a} == ${num_rules} && ${b} == ${num_rules} ]]; then echo "both"
   elif [[ ${a} == ${num_rules} ]]; then echo "a"
   elif [[ ${b} == ${num_rules} ]]; then echo "b"
   else echo "unknown"
   fi
}

add() {
  instance=$1
  instance_prefix="${instance}_prefix"
  real_port="${!instance_prefix}${real}"
  stats_port="${!instance_prefix}${stats}"
  iptables -t nat -A PREROUTING -m state --state NEW -p tcp -d ${HOST_IP} --dport 80 -j REDIRECT --to ${real_port}
  iptables -t nat -A PREROUTING -m state --state NEW -p tcp -d ${HOST_IP} --dport 81 -j REDIRECT --to ${stats_port}
}

remove() {
  instance=$1
  instance_prefix="${instance}_prefix"
  real_port="${!instance_prefix}${real}"
  stats_port="${!instance_prefix}${stats}"
  iptables -t nat -D PREROUTING -m state --state NEW -p tcp -d ${HOST_IP} --dport 80 -j REDIRECT --to ${real_port}
  iptables -t nat -D PREROUTING -m state --state NEW -p tcp -d ${HOST_IP} --dport 81 -j REDIRECT --to ${stats_port}
}

prepare_config() {
  instance=$1
  instance_prefix="${instance}_prefix"
  real_port="${!instance_prefix}${real}"
  stats_port="${!instance_prefix}${stats}"
  export PORT_STATS=${stats_port}
  export PORT_HTTP=${real_port}
  eval "$(cat /etc/haproxy/haproxy.cfg| sed 's/^\(.*\)/echo "\1"/')" > /etc/haproxy/haproxy_$1.cfg
}

service_restart() {
  /usr/sbin/haproxy_$1 -p /tmp/haproxy_$1.pid -f /etc/haproxy/haproxy_$1.cfg -sf $(pidof haproxy_$1)
}

status=$(iptables_status)
echo "Currently: ${status}"

if [[ ${status} == "none" ]]; then
  echo "Initially routing to a"
  prepare_config a
  service_restart a
  add a
elif [[ ${status} == "b" ]]; then
  echo "Switching routing to a"
  prepare_config a
  service_restart a
  add a
  remove b
elif [[ ${status} == "a" ]]; then
  echo "Switching routing to b"
  prepare_config b
  service_restart b
  add b
  remove a
else
  echo "[ERROR] unknown ipfilters state!"
  iptables -t nat -L -n -v
fi
