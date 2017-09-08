#!/bin/bash

if [[ $# -lt 1 ]]; then
  echo "stop-jenkins admin-password"
  exit 1
fi

#Check Jenkins come down ...
function checkJenkinsIsDown {
  COUNTER=0
  echo "Waiting for Jenkins to be down ..."
  JENKINS_UP="$(curl -I  --stderr /dev/null http://localhost:8080/cli/ | head -1 | cut -d' ' -f2)"
  while [[ "200" == "$JENKINS_UP" && $COUNTER -lt 60 ]]
  do
    sleep 10
    echo "Waiting for Jenkins to be down ..."
    JENKINS_UP="$(curl -I  --stderr /dev/null http://localhost:8080/cli/ | head -1 | cut -d' ' -f2)"
    let COUNTER=COUNTER+1
  done
}
#Check Jenkins isdown ...
function getJenkinsIsDown {
  COUNTER=0
  JENKINS_UP="$(curl -I  --stderr /dev/null http://localhost:8080/cli/ | head -1 | cut -d' ' -f2)"
  if [[ "200" != "$JENKINS_UP" ]]; then
    echo "true"
  else
    echo "false"
  fi
}


JENKINS_STATUS="$(ps -eaf | grep java | grep 'jenkins.war'| grep -v grep)"

if ! [[ -z "$JENKINS_STATUS" ]]; then
  execute-cli-command $1 safe-shutdown
  echo "Jenkins Server stopped, waiting to be down ..."
  checkJenkinsIsDown
  STATE="$(getJenkinsIsDown)"
  echo "Jenkins Server stopped : $STATE"
else
  echo "Jenkins Server NOT running!!"
fi
