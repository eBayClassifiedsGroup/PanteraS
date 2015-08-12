#!/bin/bash

echo "#### new keepalived config ####"
cat /etc/keepalived/keepalived.conf
service keepalived restart || true
