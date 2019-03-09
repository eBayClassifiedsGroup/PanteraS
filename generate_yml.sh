#!/bin/bash
# docker-compose.yml generator
#

[ -f docker-compose.yml.tpl ] || {
  echo "Error: docker-compose.yml.tpl need to be in CWD"
  exit 1
}

mkdir -p ./restricted
touch ./restricted/env

[ -f /etc/default/panteras ]  && . /etc/default/panteras
[ -f ./restricted/common ]    && . ./restricted/common
[ -f ./restricted/host ]      && . ./restricted/host
[ -f ./restricted/overwrite ] && . ./restricted/overwrite

echo "Keep in mind, to set free these ports on DOCKER HOST:"
echo "53, 80, 81, 2181, 2888, 3888, 5050, 5151, 8080, 8300 - 8302, 8400, 8500, 8600, 9000, 31000 - 32000"
echo "and be sure that your hostname is resolvable, if not, configure dns in /etc/resolv.conf or add entry in /etc/hosts"

# Try to detect IP
# docker-machine / boot2docker
[ ${DOCKER_HOST} ] && IP=${IP:-$(echo $DOCKER_HOST | sed 's;.*//\(.*\):.*;\1;')}
[ ${DOCKER_MACHINE_NAME} ] && HOSTNAME=${DOCKER_MACHINE_NAME} && FQDN=$HOSTNAME
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

# allow to specify a specific docker image or a specific tag of the pass-in-a-box image
PANTERAS_IMAGE_TAG=${PANTERAS_IMAGE_TAG:-$(cat infrastructure/version)} #'
echo $PANTERAS_IMAGE_TAG
PANTERAS_DOCKER_IMAGE=${PANTERAS_DOCKER_IMAGE:-${REGISTRY}panteras/paas-in-a-box:${PANTERAS_IMAGE_TAG}}

#COMMON
START_CONSUL=${START_CONSUL:-"true"}
START_FABIO=${START_FABIO:-"true"}

#MASTER
START_MESOS_MASTER=${START_MESOS_MASTER:-${MASTER}}
START_MARATHON=${START_MARATHON:-${MASTER}}
START_ZOOKEEPER=${START_ZOOKEEPER:-${MASTER}}

#SLAVE
START_CONSUL_TEMPLATE=${START_CONSUL_TEMPLATE:-${SLAVE}}
START_MESOS_SLAVE=${START_MESOS_SLAVE:-${SLAVE}}
START_REGISTRATOR=${START_REGISTRATOR:-${SLAVE}}

#OPTIONAL
START_NETDATA=${START_NETDATA:-"false"}
START_DNSMASQ=${START_DNSMASQ:-"false"}

# Lets consul behave as a client but on slaves only
[ "${SLAVE}" == "true" ] && [ "${MASTER}" == "false" ] && CONSUL_MODE=${CONSUL_MODE:-' '}
CONSUL_MODE=${CONSUL_MODE:-'-server'}

# IP that have to be specified (cannot be 0.0.0.0)
#
HOST_IP=${HOST_IP:-${IP}}
# Consul advertise IP
CONSUL_IP=${CONSUL_IP:-${LISTEN_IP}}
CONSUL_IP=${CONSUL_IP:-${IP}}
# IP for listening
LISTEN_IP=${LISTEN_IP:-0.0.0.0}

CONSUL_DC=${CONSUL_DC:-"UNKNOWN"}
CONSUL_DOMAIN=${CONSUL_DOMAIN:-"consul"}
CONSUL_BOOTSTRAP=${CONSUL_BOOTSTRAP:-'-bootstrap-expect 1'}
CONSUL_HOSTS=${CONSUL_HOSTS:-${CONSUL_BOOTSTRAP}}
MESOS_CLUSTER_NAME=${CLUSTER_NAME:-"mesoscluster"}
MESOS_MASTER_QUORUM=${MESOS_MASTER_QUORUM:-"1"}
ZOOKEEPER_HOSTS=${ZOOKEEPER_HOSTS:-"${HOSTNAME}:2181"}
ZOOKEEPER_ID=${ZOOKEEPER_ID:-"0"}
GOMAXPROCS=${GOMAXPROCS:-"4"}
FQDN=${FQDN:-"`hostname -f`"}
FQDN=${FQDN:-${HOSTNAME}}

# Memory settings
ZOOKEEPER_JAVA_OPTS=${ZOOKEEPER_JAVA_OPTS:-"-Xmx512m"}

# Disable dnsmasq address re-mapping on non slaves
[ "${SLAVE}" == "false" ] && DNSMASQ_ADDRESS=${DNSMASQ_ADDRESS:-' '}
# dnsmaq cannot be set to listen on 0.0.0.0 - it causes lot of issues
# and by default it works on all addresses
DNSMASQ_ADDRESS=${DNSMASQ_ADDRESS:-"--address=/consul/${CONSUL_IP}"}
[ ${LISTEN_IP} != "0.0.0.0" ] && DNSMASQ_BIND_INTERFACES="--bind-interfaces --listen-address=${LISTEN_IP}"

# Expose ports depends on which service has been mark to start
[ "${START_FABIO}"         == "true" ] && PORTS="ports:" && FABIO_UI_PORTS='- "81:81"'
[ "${START_CONSUL}"        == "true" ] && PORTS="ports:" && CONSUL_UI_PORTS='- "8500:8500"'
[ "${START_MARATHON}"      == "true" ] && PORTS="ports:" && MARATHON_PORTS='- "8080:8080"'
[ "${START_MESOS_MASTER}"  == "true" ] && PORTS="ports:" && MESOS_PORTS='- "5050:5050"'
[ "${START_NETDATA}"       == "true" ] && PORTS="ports:" && NETDATA_PORTS='- "19999:19999"'

# Override docker with local binary
[ "${HOST_DOCKER}" == "true" ] && VOLUME_DOCKER=${VOLUME_DOCKER:-'- "/usr/local/bin/docker:/usr/local/bin/docker"'}

# Parameters for every supervisord command
#
# -config-dir=/etc/consul.d/ \
CONSUL_PARAMS="agent \
 -client=${LISTEN_IP} \
 -advertise=${CONSUL_IP} \
 -bind=${LISTEN_IP} \
 -data-dir=/opt/consul/data \
 -ui \
 -node=${HOSTNAME} \
 -datacenter=${CONSUL_DC} \
 -domain ${CONSUL_DOMAIN} \
 ${CONSUL_MODE} \
 ${CONSUL_HOSTS} \
 ${CONSUL_PARAMS}"
#
DNSMASQ_PARAMS="-d \
 -u dnsmasq \
 -r /etc/resolv.conf.orig \
 -7 /etc/dnsmasq.d \
 --server=/${CONSUL_DOMAIN}/${CONSUL_IP}#8600 \
 --host-record=${HOSTNAME},${CONSUL_IP} \
 ${DNSMASQ_BIND_INTERFACES} \
 ${DNSMASQ_ADDRESS} \
 ${DNSMASQ_PARAMS}"
#
MARATHON_PARAMS="--master zk://${ZOOKEEPER_HOSTS}/mesos \
 --zk zk://${ZOOKEEPER_HOSTS}/marathon \
 --hostname ${HOSTNAME} \
 --http_address ${LISTEN_IP} \
 --https_address ${LISTEN_IP} \
 ${MARATHON_PARAMS}"
#
MESOS_MASTER_PARAMS="--zk=zk://${ZOOKEEPER_HOSTS}/mesos \
 --work_dir=/var/lib/mesos \
 --quorum=${MESOS_MASTER_QUORUM} \
 --ip=${LISTEN_IP} \
 --hostname=${FQDN} \
 --cluster=${MESOS_CLUSTER_NAME} \
 ${MESOS_MASTER_PARAMS}"
#
MESOS_SLAVE_PARAMS="--master=zk://${ZOOKEEPER_HOSTS}/mesos \
 --containerizers=docker,mesos \
 --executor_registration_timeout=5mins \
 --hostname=${FQDN} \
 --ip=${LISTEN_IP} \
 --docker_stop_timeout=5secs \
 --docker_socket=/var/run/docker.sock \
 --no-systemd_enable_support \
 --work_dir=/tmp/mesos \
 ${MESOS_SLAVE_PARAMS}"
# --docker_mesos_image=${PANTERAS_DOCKER_IMAGE} \
#
REGISTRATOR_PARAMS="-cleanup -ip=${HOST_IP} consul://${CONSUL_IP}:8500 \
 ${REGISTRATOR_PARAMS}"
#
ZOOKEEPER_PARAMS="start-foreground"
#
FABIO_PARAMS="-cfg ./fabio.properties"
#
NETDATA_PARAMS="-nd -ch /host"

CONSUL_APP_PARAMS=${CONSUL_APP_PARAMS:-$CONSUL_PARAMS}
DNSMASQ_APP_PARAMS=${DNSMASQ_APP_PARAMS:-$DNSMASQ_PARAMS}
MARATHON_APP_PARAMS=${MARATHON_APP_PARAMS:-$MARATHON_PARAMS}
MESOS_MASTER_APP_PARAMS=${MESOS_MASTER_APP_PARAMS:-$MESOS_MASTER_PARAMS}
MESOS_SLAVE_APP_PARAMS=${MESOS_SLAVE_APP_PARAMS:-$MESOS_SLAVE_PARAMS}
REGISTRATOR_APP_PARAMS=${REGISTRATOR_APP_PARAMS:-$REGISTRATOR_PARAMS}
ZOOKEEPER_APP_PARAMS=${ZOOKEEPER_APP_PARAMS:-$ZOOKEEPER_PARAMS}
FABIO_APP_PARAMS=${FABIO_APP_PARAMS:-$FABIO_PARAMS}
NETDATA_APP_PARAMS=${NETDATA_APP_PARAMS:-$NETDATA_PARAMS}

PANTERAS_HOSTNAME=${PANTERAS_HOSTNAME:-${HOSTNAME}}
PANTERAS_RESTART=${PANTERAS_RESTART:-"no"}


eval "$(cat docker-compose.yml.tpl| sed 's/"/+++/g'|sed  's/^\(.*\)$/echo "\1"/')" |sed 's/+++/"/g'|sed 's;\\";";g' > docker-compose.yml
