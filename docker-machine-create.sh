#!/bin/sh

docker-machine create -d virtualbox \
    --engine-storage-driver overlay \
    --virtualbox-memory=2048 \
    --virtualbox-disk-size "30000" \
    PanteraS

