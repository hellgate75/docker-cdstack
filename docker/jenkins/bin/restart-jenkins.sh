#!/bin/bash

# if [[ $# -lt 1 ]]; then
#   echo "restart-jenkins admin-password"
#   exit 1
# fi

terminate-jenkins

sleep 5

start-jenkins
