#!/bin/bash

maintenance(){
  # Mesos provides external ports in coma separated $PORTS
  for port in $(sed 's/,/ /g'<<<${PORTS})
  do
    # For each extenal ports you can map internal one from PORT_${int}
    port_int=$(env|sed -n "s/PORT_\([0-9]*\)=$port/\1/p")
    # registartor use ServiceID that contains variables, which are now all available
    consul_service_id="${HOST}-registrator:${CONTAINER_NAME}:${port_int}"
    curl -X PUT "http://${HOST}:8500/v1/agent/service/maintenance/${consul_service_id}?enable=true"
    # if you use udp uncomment also the udp to switch into maintenance mode
    #curl -X PUT "http://${HOST}:8500/v1/agent/service/maintenance/${consul_service_id}:udp?enable=true"
  done
}

trap 'maintenance && sleep 2 && kill -TERM $PID' TERM INT

cd /opt/web/
/usr/bin/python3 -m http.server --cgi &
PID=$!
wait $PID
trap - TERM INT
wait $PID
EXIT_STATUS=$?



