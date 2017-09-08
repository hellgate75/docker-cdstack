#!/bin/bash

if [[ $# -lt 2 ]]; then
  echo "execute-cli-file admin-password command ..."
  exit 1
fi

if [[ -e /var/jenkins_home/war/WEB-INF/jenkins-cli.jar ]]; then
  if [[ "nopassword" == "$1" ]]; then
    if [[ $# -gt 2 ]]; then
      java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080/ ${@:2} 2> /dev/null
    else
      java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080/ $2 2> /dev/null
    fi
  else
    if [[ $# -gt 2 ]]; then
      java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080/ -auth "admin:$1" ${@:2} 2> /dev/null
    else
      java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080/ -auth "admin:$1" $2 2> /dev/null
    fi
  fi
  exit $?
else
  echo 'Jekins Client jar not found ...'
  exit 1
fi
