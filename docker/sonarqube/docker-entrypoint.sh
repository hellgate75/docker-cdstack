#!/bin/bash

if [[ ! -z "$(echo $3|grep "\-daemon")" || -z "$1" ]]; then
  echo "Running docker SonarQube Server ..."
  chmod 777 /docker-start-sonarqube.sh
  /docker-start-sonarqube.sh -daemon
else
  echo "Executing command : $@"
  exec "$@"
fi
