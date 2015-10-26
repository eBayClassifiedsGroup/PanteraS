#!/bin/bash
./haproxy_reload.sh
trap './haproxy_reload.sh cleanup && kill -TERM $PID' TERM INT
consul-template ${CONSUL_TEMPLATE_APP_PARAMS} -max-stale=0 &
PID=$!
wait $PID
trap - TERM INT
wait $PID
exit $?

