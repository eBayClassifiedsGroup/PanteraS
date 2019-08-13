panteras:
  image:      ${PANTERAS_DOCKER_IMAGE}
#  net:        bridge
  net:        host
  privileged: true
  pid:        host
  restart:    "${PANTERAS_RESTART}"
  ${PORTS}
     ${FABIO_UI_PORTS} 
     ${TRAEFIK_UI_PORTS}
     ${CONSUL_UI_PORTS} 
     ${MARATHON_PORTS}
     ${MESOS_PORTS}
     ${NETDATA_PORTS}
     - "9000:9000"
  
  environment:
    CONSUL_IP:               "${CONSUL_IP}"
    HOST_IP:                 "${HOST_IP}"
    LISTEN_IP:               "${LISTEN_IP}"
    FQDN:                    "${FQDN}"
    GOMAXPROCS:              "${GOMAXPROCS}"

    SERVICE_81_NAME: router-ui
    SERVICE_81_TAGS: paas-router.ui.service.consul/
    SERVICE_81_CHECK_HTTP: /routes

    SERVICE_8500_NAME: consul-ui
    SERVICE_8500_TAGS: paas-consul.ui.service.consul/
    SERVICE_8500_CHECK_HTTP: /v1/status/leader

    SERVICE_8080_NAME: marathon
    SERVICE_8080_TAGS: paas-marathon.ui.service.consul/
    SERVICE_8080_CHECK_HTTP: /v2/leader

    SERVICE_5050_NAME: mesos
    SERVICE_5050_TAGS: paas-mesos.service.consul/
    SERVICE_5050_CHECK_HTTP: /master/health

    SERVICE_19999_NAME: netdata
    SERVICE_19999_TAGS: paas-netdata.service.consul/
    SERVICE_19999_CHECK_HTTP: /version.txt

    START_CONSUL:            "${START_CONSUL}"
    START_DNSMASQ:           "${START_DNSMASQ}"
    START_MESOS_MASTER:      "${START_MESOS_MASTER}"
    START_MARATHON:          "${START_MARATHON}"
    START_MESOS_SLAVE:       "${START_MESOS_SLAVE}"
    START_REGISTRATOR:       "${START_REGISTRATOR}"
    START_ZOOKEEPER:         "${START_ZOOKEEPER}"
    START_FABIO:             "${START_FABIO}"
    START_TRAEFIK:           "${START_TRAEFIK}"
    START_NETDATA:           "${START_NETDATA}"

    CONSUL_APP_PARAMS:          "${CONSUL_APP_PARAMS}"
    CONSUL_DOMAIN:              "${CONSUL_DOMAIN}"
    DNSMASQ_APP_PARAMS:         "${DNSMASQ_APP_PARAMS}"
    MARATHON_APP_PARAMS:        "${MARATHON_APP_PARAMS}"
    MESOS_MASTER_APP_PARAMS:    "${MESOS_MASTER_APP_PARAMS}"
    MESOS_SLAVE_APP_PARAMS:     "${MESOS_SLAVE_APP_PARAMS}"
    REGISTRATOR_APP_PARAMS:     "${REGISTRATOR_APP_PARAMS}"
    JVMFLAGS:                   "${ZOOKEEPER_JAVA_OPTS}"
    ZOOKEEPER_APP_PARAMS:       "${ZOOKEEPER_APP_PARAMS}"
    ZOOKEEPER_HOSTS:            "${ZOOKEEPER_HOSTS}"
    ZOOKEEPER_ID:               "${ZOOKEEPER_ID}"
    FABIO_APP_PARAMS:           "${FABIO_APP_PARAMS}"
    TRAEFIK_APP_PARAMS:         "${TRAEFIK_APP_PARAMS}"
    NETDATA_APP_PARAMS:         "${NETDATA_APP_PARAMS}"

    HOSTNAME:                   "${PANTERAS_HOSTNAME}"

  env_file:
    ./restricted/env

  volumes:
    - "/etc/resolv.conf:/etc/resolv.conf.orig"
#    - "/var/spool/marathon/artifacts/store:/var/spool/store"
    - "/var/run/docker.sock:/tmp/docker.sock"
    - "/var/run/docker.sock:/var/run/docker.sock"
    - "/var/lib/docker:/var/lib/docker"
    - "/sys:/sys"
    - "/tmp/mesos:/tmp/mesos${SHARED}"
    - "/tmp/supervisord:/tmp/supervisord"
    - "/tmp/consul/data:/opt/consul/data"
    - "/tmp/zookeeper:/var/lib/zookeeper/version-2"
    - "/proc:/host/proc:ro" 
    - "/sys:/host/sys:ro"
    ${VOLUME_DOCKER}
