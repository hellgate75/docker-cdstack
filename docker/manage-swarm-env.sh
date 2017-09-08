#!/bin/bash

source scripts/common-functions.sh

if [[ "local" != "$1" && "azure" != "$1" ]]; then
  echo "Error: Invalid environment"
  echo "$(usage)"
  exit 0
fi
ENVIRONMENT="$1"


##########################################################################
## Execute Swarm Cluser operations with script parameters:              ##
##  - command (--create|--destory|--start|--stop|--redeploy)            ##
##  - environment (local|azure) and/or :                                ##
##  - suffix (suffix for docker-machine name)                           ##
##########################################################################
if [[ "local" == "$1" ]]; then
  source scripts/manage-local-swarm.sh ${@:2}
  exit 0
# elif [[ "azure" == "$1" ]]; then
#   exit 0
else
  echo "Error: Environment $1 has not been implemented yet!!"
  echo "$(usage)"
  exit 1
fi
