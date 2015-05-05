#!/bin/bash

[ -f ./restricted/common ]    && . ./restricted/common
[ -f ./restricted/host ]      && . ./restricted/host
[ -f ./restricted/overwrite ] && . ./restricted/overwrite

B2D=""
which boot2docker && {
  boot2docker init
  boot2docker start
  $(boot2docker shellinit)
  HOSTNAME=boot2docker
  B2D="boot2docker ssh"
  FQDN=$HOSTNAME
}

# detect DOCKERHOST IP
[ -z $DOCKER_HOST ] || IP=$(echo $DOCKER_HOST | sed 's;.*//\(.*\):.*;\1;')
IP=${IP:-$(ifconfig | awk '/inet .*10/{gsub(/.*:/,"",$2);print $2;exit}')}




# Defaults for stand alone mode
MASTER=${MASTER:-"true"}
SLAVE=${SLAVE:-"true"}
#
#COMMON
START_CONSUL=${START_CONSUL:-"true"}
#MASTER
START_MESOS_MASTER=${START_MESOS_MASTER:-${MASTER}}
START_MARATHON=${START_MARATHON:-${MASTER}}
START_ZOOKEEPER=${START_ZOOKEEPER:-${MASTER}}
#SLAVE 
START_CONSUL_TEMPLATE=${START_CONSUL_TEMPLATE:-${SLAVE}}
START_HAPROXY=${START_HAPROXY:-${SLAVE}}
START_MESOS_SLAVE=${START_MESOS_SLAVE:-${SLAVE}}
START_REGISTRATOR=${START_REGISTRATOR:-${SLAVE}}
#OPTIONAL
START_DNSMASQ=${START_DNSMASQ:-"true"}

# Lets consul behave as a client but on slaves only
[ "${SLAVE}" == "true" ] && [ "${MASTER}" == "false" ] && CONSUL_MODE=${CONSUL_MODE:-''}
CONSUL_MODE=${CONSUL_MODE:-'-server'}

HOST_IP=${IP}
CONSUL_IP=${IP}
CONSUL_DC=${CONSUL_DC:-"UNKNOWN"}
CONSUL_BOOTSTRAP=${CONSUL_BOOTSTRAP:-'-bootstrap-expect 1'}
CONSUL_HOSTS=${CONSUL_HOSTS:-${CONSUL_BOOTSTRAP}}
MESOS_CLUSTER_NAME=${CLUSTER_NAME:-"mesoscluster"}
ZOOKEEPER_HOSTS=${ZOOKEEPER_HOSTS:-"${HOSTNAME}:2181"}
ZOOKEEPER_ID=${ZOOKEEPER_ID:-"0"}
GOMAXPROCS=${GOMAXPROCS:-"4"}
FQDN=${FQDN:-"`hostname -f`"}

# Parameters for every supervisord command
#
# -config-dir=/etc/consul.d/ \
CONSUL_PARAMS="agent \
 -client=0.0.0.0 \
 -data-dir=/opt/consul/ \
 -ui-dir=/opt/consul/dist/ \
 -advertise=${HOST_IP} \
 -node=${HOSTNAME} \
 -dc=${CONSUL_DC} \
 ${CONSUL_MODE} \
 ${CONSUL_HOSTS} \
 ${CONSUL_PARAMS}"
#
CONSUL_TEMPLATE_PARAMS="-consul=${CONSUL_IP}:8500 \
 -template template.conf:/etc/haproxy/haproxy.cfg:/opt/consul-template/haproxy_reload.sh"
#
DNSMASQ_PARAMS="-d \
 -u dnsmasq \
 -r /etc/resolv.conf \
 -7 /etc/dnsmasq.d \
 --server=/consul/${CONSUL_IP}#8600 \
 --address=/consul/${CONSUL_IP} \
 --host-record=${HOSTNAME},${CONSUL_IP} \
 ${DNSMASQ_PARAMS}"
#
HAPROXY_RELOAD_COMMAND="/usr/sbin/haproxy -p /tmp/haproxy.pid -f /etc/haproxy/haproxy.cfg -sf \$(pidof /usr/sbin/haproxy) || true"
#
MARATHON_PARAMS="--master zk://${ZOOKEEPER_HOSTS}/mesos \
 --zk zk://${ZOOKEEPER_HOSTS}/marathon \
 --hostname ${HOSTNAME} \
 ${MARATHON_PARAMS}"
#
MESOS_MASTER_PARAMS="--zk=zk://${ZOOKEEPER_HOSTS}/mesos \
 --work_dir=/var/lib/mesos \
 --quorum=1 \
 --ip=0.0.0.0 \
 --hostname=${FQDN} \
 --cluster=${MESOS_CLUSTER_NAME} \
 ${MESOS_MASTER_PARAMS}"
#
MESOS_SLAVE_PARAMS="--master=zk://${ZOOKEEPER_HOSTS}/mesos \
 --containerizers=docker,mesos \
 --executor_registration_timeout=5mins \
 --hostname=${FQDN} \
 --docker_stop_timeout=5secs \
 ${MESOS_SLAVE_PARAMS}"
#
REGISTRATOR_PARAMS="-ip=${HOST_IP} consul://${CONSUL_IP}:8500 \
 ${REGISTRATOR_PARAMS}"
#
ZOOKEEPER_PARAMS="start-foreground"


CONSUL_APP_PARAMS=${CONSUL_APP_PARAMS:-$CONSUL_PARAMS}
CONSUL_TEMPLATE_APP_PARAMS=${CONSUL_TEMPLATE_APP_PARAMS:-$CONSUL_TEMPLATE_PARAMS}
DNSMASQ_APP_PARAMS=${DNSMASQ_APP_PARAMS:-$DNSMASQ_PARAMS}
HAPROXY_RELOAD_COMMAND=${HAPROXY_RELOAD_COMMAND:-$HAPROXY_RELOAD_COMMAND}
MARATHON_APP_PARAMS=${MARATHON_APP_PARAMS:-$MARATHON_PARAMS}
MESOS_MASTER_APP_PARAMS=${MESOS_MASTER_APP_PARAMS:-$MESOS_MASTER_PARAMS}
MESOS_SLAVE_APP_PARAMS=${MESOS_SLAVE_APP_PARAMS:-$MESOS_SLAVE_PARAMS}
REGISTRATOR_APP_PARAMS=${REGISTRATOR_APP_PARAMS:-$REGISTRATOR_PARAMS}
ZOOKEEPER_APP_PARAMS=${ZOOKEEPER_APP_PARAMS:-$ZOOKEEPER_PARAMS}

# DNS manipulation
# You can change your resolv.conf inside panetras image
# just cerate /etc/resolv.conf.paas on docker host wih your content
#
RESOLV_CONF='/etc/resolv.conf'
$B2D [ -f /etc/resolv.conf.paas ] 2>/dev/null && RESOLV_CONF='/etc/resolv.conf.paas'

eval "$(cat docker-compose.yml.tpl| sed 's/"/+++/g'|sed  's/^\(.*\)$/echo "\1"/')" |sed 's/+++/"/g'|sed 's;\\";";g' > docker-compose.yml
