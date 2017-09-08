#!/bin/bash

if [[ $# -lt 3 ]]; then
  echo "execute-cli-file admin-password file-path command ..."
  exit 1
fi

if [[ -e /var/jenkins_home/war/WEB-INF/jenkins-cli.jar ]]; then
  if [[ "nopassword" == "$1" ]]; then
    if [[ $# -gt 3 ]]; then
      java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080/ ${@:3} < $2 2> /dev/null
    else
      java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080/ $3 < $2 2> /dev/null
    fi
  else
    if [[ $# -gt 3 ]]; then
      java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080/ -auth "admin:$1" ${@:3} < $2 2> /dev/null
    else
      java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080/ -auth "admin:$1" $3 < $2 2> /dev/null
    fi
  fi
  exit $?
else
  echo 'Jekins Client jar not found ...'
  exit 1
fi
