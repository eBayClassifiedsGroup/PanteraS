panteras:
  image:      ${PANTERAS_DOCKER_IMAGE}
  net:        host
  privileged: true
  restart:    "${PANTERAS_RESTART}"
  ${PORTS}
     ${CONSUL_UI_PORTS} 
     ${MARATHON_PORTS}
     ${MESOS_PORTS}
     ${CHRONOS_PORTS}
  
  environment:
    CONSUL_IP:               "${CONSUL_IP}"
    HOST_IP:                 "${HOST_IP}"
    LISTEN_IP:               "${LISTEN_IP}"
    FQDN:                    "${FQDN}"
    GOMAXPROCS:              "${GOMAXPROCS}"

    SERVICE_8500_NAME: consul-ui
    SERVICE_8500_TAGS: haproxy
    SERVICE_8500_CHECK_HTTP: /v1/status/leader

    SERVICE_8080_NAME: marathon
    SERVICE_8080_TAGS: haproxy
    SERVICE_8080_CHECK_HTTP: /v2/leader

    SERVICE_5050_NAME: mesos
    SERVICE_5050_TAGS: haproxy
    SERVICE_5050_CHECK_HTTP: /master/health

    SERVICE_4400_NAME: chronos
    SERVICE_4400_TAGS: haproxy
    SERVICE_4400_CHECK_HTTP: /ping

    START_CONSUL:            "${START_CONSUL}"
    START_CONSUL_TEMPLATE:   "${START_CONSUL_TEMPLATE}"
    START_DNSMASQ:           "${START_DNSMASQ}"
    START_MESOS_MASTER:      "${START_MESOS_MASTER}"
    START_MARATHON:          "${START_MARATHON}"
    START_MESOS_SLAVE:       "${START_MESOS_SLAVE}"
    START_REGISTRATOR:       "${START_REGISTRATOR}"
    START_ZOOKEEPER:         "${START_ZOOKEEPER}"
    START_CHRONOS:           "${START_CHRONOS}"
    START_FABIO:             "${START_FABIO}"

    CONSUL_APP_PARAMS:          "${CONSUL_APP_PARAMS}"
    CONSUL_DOMAIN:              "${CONSUL_DOMAIN}"
    CONSUL_TEMPLATE_APP_PARAMS: "${CONSUL_TEMPLATE_APP_PARAMS}"
    DNSMASQ_APP_PARAMS:         "${DNSMASQ_APP_PARAMS}"
    HAPROXY_ADD_DOMAIN:         "${HAPROXY_ADD_DOMAIN}"
    MARATHON_APP_PARAMS:        "${MARATHON_APP_PARAMS}"
    MESOS_MASTER_APP_PARAMS:    "${MESOS_MASTER_APP_PARAMS}"
    MESOS_SLAVE_APP_PARAMS:     "${MESOS_SLAVE_APP_PARAMS}"
    REGISTRATOR_APP_PARAMS:     "${REGISTRATOR_APP_PARAMS}"
    ZOOKEEPER_APP_PARAMS:       "${ZOOKEEPER_APP_PARAMS}"
    ZOOKEEPER_HOSTS:            "${ZOOKEEPER_HOSTS}"
    ZOOKEEPER_ID:               "${ZOOKEEPER_ID}"
    KEEPALIVED_VIP:             "${KEEPALIVED_VIP}"
    CHRONOS_APP_PARAMS:         "${CHRONOS_APP_PARAMS}"
    FABIO_APP_PARAMS:           "${FABIO_APP_PARAMS}"

    HOSTNAME:                   "${PANTERAS_HOSTNAME}"

  env_file:
    ./restricted/env

  volumes:
    - "/etc/resolv.conf:/etc/resolv.conf.orig"
    - "/var/spool/marathon/artifacts/store:/var/spool/store"
    - "/var/run/docker.sock:/tmp/docker.sock"
    - "/var/lib/docker:/var/lib/docker"
    - "/sys:/sys"
    - "/tmp/mesos:/tmp/mesos"
    ${VOLUME_DOCKER}
