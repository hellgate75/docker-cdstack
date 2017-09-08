#!/bin/bash

JENKINS_STATUS="$(ps -eaf | grep java | grep 'jenkins.war'| grep -v grep)"

if ! [[ -z "$JENKINS_STATUS" ]]; then
  echo "running"
else
  echo "stopped"
fi
