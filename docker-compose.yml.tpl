panteras:
  dns: ${HOST_IP}
  image: panteras
  name: panteras
  net: host
  privileged: true

  environment:
    MASTER:                  "${MASTER}"
    CONSUL_IP:               "${CONSUL_IP}"
    HOST_IP:                 "${HOST_IP}"
    GOMAXPROCS:              "${GOMAXPROCS}"
    DNSMASQ_START:           "${DNSMASQ_START}"

    CONSUL_APP_PARAMS:       "${CONSUL_APP_PARAMS}"
    DNSMASQ_APP_PARAMS:      "${DNSMASQ_APP_PARAMS}"
    HAPROXY_APP_PARAMS:      "${HAPROXY_APP_PARAMS}"
    HAPROXY_APP_RELOAD:      "${HAPROXY_APP_RELOAD}"
    MARATHON_APP_PARAMS:     "${MARATHON_APP_PARAMS}"
    MESOS_MASTER_APP_PARAMS: "${MESOS_MASTER_APP_PARAMS}"
    MESOS_SLAVE_APP_PARAMS:  "${MESOS_SLAVE_APP_PARAMS}"
    REGISTRATOR_APP_PARAMS:  "${REGISTRATOR_APP_PARAMS}"
    ZOOKEEPER_APP_PARAMS:    "${ZOOKEEPER_APP_PARAMS}"
    ZOOKEEPER_HOSTS:         "${ZOOKEEPER_HOSTS}"
    ZOOKEEPER_ID:            "${ZOOKEEPER_ID}"

  volumes:
    - "${RESOLV_CONF}:/etc/resolv.conf"
    - "/var/spool/marathon/artifacts/store:/var/spool/store"
    - "/var/run/docker.sock:/tmp/docker.sock"
    - "/var/lib/docker:/var/lib/docker"
    - "/sys:/sys"
    - "/tmp/mesos:/tmp/mesos"
