#!/bin/bash

if [[ $# -lt 2 ]]; then
  echo "execute-groovy-script admin-password file-path arguments..."
  exit 1
fi
#    java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080/ -auth admin:jenkins groovy = < $PWD/basic-security-1503254236.groovy
if [[ -e /var/jenkins_home/war/WEB-INF/jenkins-cli.jar ]]; then
  if [[ "nopassword" == "$1" ]]; then
    if [[ $# -gt 2 ]]; then
      java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080/ groovy = ${@:3} < $2 2> /dev/null
    else
      java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080/ groovy = < $2 2> /dev/null
    fi
  else
    if [[ $# -gt 2 ]]; then
      java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080/ -auth "admin:$1" groovy = ${@:3} < $2 2> /dev/null
    else
      java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080/ -auth "admin:$1" groovy = < $2 2> /dev/null
    fi
  fi
  exit $?
else
  echo 'Jekins Client jar not found ...'
  exit 1
fi
