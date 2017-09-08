#!/bin/bash

JENKINS_STATUS="$(ps -eaf | grep java | grep 'jenkins.war'| grep -v grep)"

#Check Jenkins come up and running ...
function checkJenkinsIsUp {
  COUNTER=0
  echo "Waiting for Jenkins to be up and running ..."
  JENKINS_UP="$(curl -I  --stderr /dev/null http://localhost:8080/cli/ | head -1 | cut -d' ' -f2)"
  while [[ "200" != "$JENKINS_UP" && $COUNTER -lt 60 ]]
  do
    sleep 10
    echo "Waiting for Jenkins to be up and running ..."
    JENKINS_UP="$(curl -I  --stderr /dev/null http://localhost:8080/cli/ | head -1 | cut -d' ' -f2)"
    let COUNTER=COUNTER+1
  done
}

#Check Jenkins is up and running ...
function getJenkinsIsUp {
  COUNTER=0
  JENKINS_UP="$(curl -I  --stderr /dev/null http://localhost:8080/cli/ | head -1 | cut -d' ' -f2)"
  if [[ "200" == "$JENKINS_UP" ]]; then
    echo "true"
  else
    echo "false"
  fi
}

if [[ -z "$JENKINS_STATUS" ]]; then
  # export JAVA_OPTS="-Xms${JAVA_MIN_HEAP:-"256m"} -Xmx${JAVA_MAX_HEAP:-"1G"} -Djava.awt.headless=true -Djenkins.install.runSetupWizard=false -Dhudson.model.ParametersAction.keepUndefinedParameters=true -Dhudson.model.DirectoryBrowserSupport.CSP=\"sandbox allow-scripts; style-src 'unsafe-inline' *;script-src 'unsafe-inline' *;\""
  export JAVA_OPTS="-Xms${JAVA_MIN_HEAP:-"256m"} -Xmx${JAVA_MAX_HEAP:-"1G"} -Djava.awt.headless=true -Djenkins.install.runSetupWizard=false -Dhudson.model.ParametersAction.keepUndefinedParameters=true"

  sudo mkdir -p /var/log/jenkins

  sudo chown -Rf jenkins:jenkins /var/log/jenkins

  # if [[ -e $JENKINS_HOME/.jenkins/admin-config.xml ]]; then
  #   if ! [[ -e $JENKINS_HOME/users ]]; then
  #     if ! [[ -e $JENKINS_HOME/users/admin ]]; then
  #       if ! [[ -e $JENKINS_HOME/users/admin/config.xml ]]; then
  #         cp $JENKINS_HOME/.jenkins/admin-config.xml $JENKINS_HOME/users/admin/config.xml
  #       fi
  #     fi
  #   fi
  # fi

  bash -c "nohup /usr/local/bin/jenkins.sh &> /var/log/jenkins/jenkins.log  &"
  echo "Jenkins Server started, waiting to be up ..."
  checkJenkinsIsUp
  STATE="$(getJenkinsIsUp)"
  echo "Jenkins Server started : $STATE"
  # if [[ -e $JENKINS_HOME/.jenkins/admin-config.xml ]]; then
  #   if ! [[ -e $JENKINS_HOME/users ]]; then
  #     if ! [[ -e $JENKINS_HOME/users/admin ]]; then
  #       if ! [[ -e $JENKINS_HOME/users/admin/config.xml ]]; then
  #         cp $JENKINS_HOME/.jenkins/admin-config.xml $JENKINS_HOME/users/admin/config.xml
  #       fi
  #     fi
  #   fi
  # fi

else
  echo "Jenkins Server already running!!"
fi
