#!/bin/bash

if [[ ! -z "$(echo $3|grep "\-daemon")" || -z "$1" ]]; then
  echo "Running docker Jenkins Agent ..."
  sudo chmod 777 /docker-start-agent.sh
  /docker-start-agent.sh -daemon
else
  echo "Executing command : $@"
  exec "$@"
fi
