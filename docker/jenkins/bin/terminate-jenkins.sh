#!/bin/bash

JENKINS_STATUS="$(ps -eaf | grep java | grep 'jenkins.war'| grep -v grep)"
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

if ! [[ -z "$JENKINS_STATUS" ]]; then
  kill "$(ps -eaf | grep java | grep 'jenkins.war'| grep -v grep | awk 'BEGIN {FS=OFS=" "}{print $2}')"
  JENKINS_STATUS="$(ps -eaf | grep java | grep 'jenkins.war'| grep -v grep)"
  checkJenkinsIsDown
  sleep 5
  STATE="$(getJenkinsIsDown)"
  echo "Jenkins Server terminated : $STATE"
else
  echo "Jenkins Server NOT running!!"
fi
