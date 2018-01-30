#!/bin/bash
set -eux -o pipefail

cd $(dirname $0)

docker-compose build
docker-compose up &
job=$!

sleep 5

python setup_server.py

wait
