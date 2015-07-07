#!/bin/bash

[ -f ./restricted/common ]    && . ./restricted/common
[ -f ./restricted/host ]      && . ./restricted/host
[ -f ./restricted/overwrite ] && . ./restricted/overwrite

echo "Keep in mind, to set free these ports on DOCKERHOST"
echo "53, 80, 81, 2181, 2888, 3888, 5050, 5151, 8080, 8300-8302, 8400, 8500, 8600, 9000, 31000 - 32000"
echo "and be sure that your hostname is resolvable, if not, add entry to /etc/resolv.conf"

# detect DOCKERHOST IP if was not provided

# boot2docker
B2D=""
which boot2docker >/dev/null && {
  echo "Boot2docker detected, shall we use it (y/n)?"
  read ANSWER
  [ "$ANSWER" == "y" ] && {
    boot2docker init
    boot2docker start
    $(boot2docker shellinit)
    HOSTNAME=boot2docker
    B2D="boot2docker ssh"
    FQDN=$HOSTNAME
    [ -n "${DOCKER_HOST}" ] && IP=${IP:-$(echo $DOCKER_HOST | sed 's;.*//\(.*\):.*;\1;')}
 }
}

# Try to detect IP
# outside vagrant
which vagrant >/dev/null && IP=${IP:-$(vagrant ssh -c ifconfig 2>/dev/null| grep -oh "\w*192.168.10.10\w*")}
# inside vagrant
[ "$HOSTNAME" == "standalone" ] && IP=${IP:-192.168.10.10}
# try to guess
IP=${IP:-$(dig +short ${HOSTNAME})}

[ -z ${IP} ] && echo "env IP variable missing" && exit 1



# Defaults for stand alone mode
MASTER=${MASTER:-"true"}
SLAVE=${SLAVE:-"true"}

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
[ "${SLAVE}" == "true" ] && [ "${MASTER}" == "false" ] && CONSUL_MODE=${CONSUL_MODE:-' '}
CONSUL_MODE=${CONSUL_MODE:-'-server'}

HOST_IP=${IP}
DNS_IP=${DNS_IP}
CONSUL_IP=${IP}
CONSUL_DC=${CONSUL_DC:-"UNKNOWN"}
CONSUL_BOOTSTRAP=${CONSUL_BOOTSTRAP:-'-bootstrap-expect 1'}
CONSUL_HOSTS=${CONSUL_HOSTS:-${CONSUL_BOOTSTRAP}}
MESOS_CLUSTER_NAME=${CLUSTER_NAME:-"mesoscluster"}
MESOS_MASTER_QUORUM=${MESOS_MASTER_QUORUM:-"1"}
ZOOKEEPER_HOSTS=${ZOOKEEPER_HOSTS:-"${HOSTNAME}:2181"}
ZOOKEEPER_ID=${ZOOKEEPER_ID:-"0"}
GOMAXPROCS=${GOMAXPROCS:-"4"}
FQDN=${FQDN:-"`hostname -f`"}
FQDN=${FQDN:-${HOSTNAME}}

# Disable dnsmasq address re-mapping on non slaves - no HAProxy there
[ "${SLAVE}" == "false" ] && DNSMASQ_ADDRESS=${DNSMASQ_ADDRESS:-' '}
DNSMASQ_ADDRESS=${DNSMASQ_ADDRESS:-"--address=/consul/${CONSUL_IP}"}

# enable keepalived if the HAProxy gets started and a
# virtual IP address is specified
[ "${START_HAPROXY}" == "true" ] && [ ${KEEPALIVED_VIP} ] && \
    KEEPALIVED_CONSUL_TEMPLATE="-template=./keepalived.conf:/etc/keepalived/keepalived.conf:./keepalived_reload.sh"

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
 -template template.conf:/etc/haproxy/haproxy.cfg:/opt/consul-template/haproxy_reload.sh \
 ${KEEPALIVED_CONSUL_TEMPLATE}"
#
DNSMASQ_PARAMS="-d \
 -u dnsmasq \
 -r /etc/resolv.conf.orig \
 -7 /etc/dnsmasq.d \
 --server=/consul/${CONSUL_IP}#8600 \
 --host-record=${HOSTNAME},${CONSUL_IP} \
 ${DNSMASQ_ADDRESS} \
 ${DNSMASQ_PARAMS}"
#
#HAPROXY_RELOAD_COMMAND="/usr/sbin/haproxy -p /tmp/haproxy.pid -f /etc/haproxy/haproxy.cfg -sf \$(pidof /usr/sbin/haproxy) || true"
HAPROXY_RELOAD_COMMAND="nl-qdisc-add --dev=eth0 --parent=1:4 --id=40: --update plug --buffer &> /dev/null; /usr/sbin/haproxy -p /tmp/haproxy.pid -f /etc/haproxy/haproxy.cfg -sf \$(pidof /usr/sbin/haproxy); nl-qdisc-add --dev=eth0 --parent=1:4 --id=40: --update plug--release-indefinite &> /dev/null || true"
#
MARATHON_PARAMS="--master zk://${ZOOKEEPER_HOSTS}/mesos \
 --zk zk://${ZOOKEEPER_HOSTS}/marathon \
 --hostname ${HOSTNAME} \
 --no-logger \
 ${MARATHON_PARAMS}"
#
MESOS_MASTER_PARAMS="--zk=zk://${ZOOKEEPER_HOSTS}/mesos \
 --work_dir=/var/lib/mesos \
 --quorum=${MESOS_MASTER_QUORUM} \
 --ip=0.0.0.0 \
 --hostname=${FQDN} \
 --cluster=${MESOS_CLUSTER_NAME} \
 ${MESOS_MASTER_PARAMS}"
#
MESOS_SLAVE_PARAMS="--master=zk://${ZOOKEEPER_HOSTS}/mesos \
 --containerizers=docker,mesos \
 --executor_registration_timeout=5mins \
 --hostname=${FQDN} \
 --ip=0.0.0.0 \
 --docker_stop_timeout=5secs \
 --gc_delay=1days \
 ${MESOS_SLAVE_PARAMS}"
#
REGISTRATOR_PARAMS="-ip=${HOST_IP} consul://${CONSUL_IP}:8500 \
 ${REGISTRATOR_PARAMS}"
#
ZOOKEEPER_PARAMS="start-foreground"


CONSUL_APP_PARAMS=${CONSUL_APP_PARAMS:-$CONSUL_PARAMS}
CONSUL_TEMPLATE_APP_PARAMS=${CONSUL_TEMPLATE_APP_PARAMS:-$CONSUL_TEMPLATE_PARAMS}
DNSMASQ_APP_PARAMS=${DNSMASQ_APP_PARAMS:-$DNSMASQ_PARAMS}
HAPROXY_RELOAD_COMMAND=${HAPROXY_RELOAD_APP_COMMAND:-$HAPROXY_RELOAD_COMMAND}
MARATHON_APP_PARAMS=${MARATHON_APP_PARAMS:-$MARATHON_PARAMS}
MESOS_MASTER_APP_PARAMS=${MESOS_MASTER_APP_PARAMS:-$MESOS_MASTER_PARAMS}
MESOS_SLAVE_APP_PARAMS=${MESOS_SLAVE_APP_PARAMS:-$MESOS_SLAVE_PARAMS}
REGISTRATOR_APP_PARAMS=${REGISTRATOR_APP_PARAMS:-$REGISTRATOR_PARAMS}
ZOOKEEPER_APP_PARAMS=${ZOOKEEPER_APP_PARAMS:-$ZOOKEEPER_PARAMS}


eval "$(cat docker-compose.yml.tpl| sed 's/"/+++/g'|sed  's/^\(.*\)$/echo "\1"/')" |sed 's/+++/"/g'|sed 's;\\";";g' > docker-compose.yml
