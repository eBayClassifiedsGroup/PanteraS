#!/bin/bash
./haproxy_reload.sh
consul-template ${CONSUL_TEMPLATE_APP_PARAMS}
