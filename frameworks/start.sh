#!/bin/bash
usage(){
  cat << EOF
  This container works better when started with marathon
  Example usage:
  # cat deploy.json
  {
    "id": "foo", 
    "container": {
	"docker": {
	    "image": "${IMAGE}"
	},
	"type": "DOCKER",
	"volumes": []
    },
    "args": ["your_appliactino_here with arguments || sleep 300"],
    "cpus": 0.1,
    "mem": 32.0,
    "instances": 1
  }

  # curl -X POST -H "Content-Type: application/json" http://\$MARATHON_IP:8080/v2/apps/ -d@deploy.json

  or with marathon_deploy

  # json2yaml deploy.json > deploy.yml
  # cat deploy.yml 
  ---
  id: foo
  container:
    docker:
      image: ${IMAGE}
    type: DOCKER
    volumes: []
  args:
  - your_appliactino_here with arguments || sleep 300
  cpus: 0.1
  mem: 32.0
  instances: 1

  # marathon_deploy -e PRODUCTION 
EOF
}

maintenance(){
  # Container name will be provided by mesos:
  MESOS_CONTAINER_NAME=${MESOS_CONTAINER_NAME:-$CONTAINER_NAME}
  # Mesos provides external ports in coma separated $PORTS
  for port in $(sed 's/,/ /g'<<<${PORTS})
  do
    # For each extenal ports you can map internal one from PORT_${int}
    port_int=$(env|sed -n "s/PORT_\([0-9]*\)=$port/\1/p")
    # registartor use ServiceID that contains variables, which are now all available
    consul_service_id="${HOST%%.*}:${MESOS_CONTAINER_NAME}:${port_int}"
    curl -X PUT "http://${HOST}:8500/v1/agent/service/maintenance/${consul_service_id}?enable=true"
    # if you use udp uncomment also the udp to switch into maintenance mode
    #curl -X PUT "http://${HOST}:8500/v1/agent/service/maintenance/${consul_service_id}:udp?enable=true"
  done
}

trap 'maintenance && sleep 2 && kill -TERM $PID $PID_CUSTOM' TERM INT

[ "$1" ] || { usage; exit 1; }

# You can start your additional application
# like supervisord etc.
#
[ -f /etc/rc.custom ] && {
  /etc/rc.custom &
  PID_CUSTOM=$!
}

eval "$@" &
PID=$!
wait $PID
trap - TERM INT
wait $PID
exit $?
