#!/bin/bash

if [[ ! -z "$(echo $3|grep "\-daemon")" || -z "$1" ]]; then
  echo "Running docker Nexus3 OSS Server ..."
  sudo chmod 777 /docker-start-nexus.sh
  /docker-start-nexus.sh -daemon
else
  echo "Executing command : $@"
  exec "$@"
fi
