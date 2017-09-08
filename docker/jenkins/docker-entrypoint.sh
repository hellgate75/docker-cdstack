#!/bin/bash

if [[ ! -z "$(echo $3|grep "\-daemon")" || -z "$1" ]]; then
  echo "Running docker Jenkins Server ..."
  sudo chmod 777 /docker-start-jenkins.sh
  /docker-start-jenkins.sh -daemon
else
  echo "Executing command : $@"
  exec "$@"
fi
