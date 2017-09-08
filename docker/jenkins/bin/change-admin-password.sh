#!/bin/bash

function remove_temporary_files() {
  if [[ -e "$1" ]]; then
    echo "Removing temporary files ..."
    rm -f "$1"
  fi
}

if [[ $# -lt 1 ]]; then
  echo "change-script-admin-password admin-password"
  exit 1
fi

echo "Changing Jenkins admin password to : $1"

SALT="$(date "+%s")"

cp $JENKINS_HOME/.jenkins/basic-security.groovy.template $JENKINS_HOME/.jenkins/basic-security-$SALT.groovy

sed -i "s/JENKINS_ADMIN_PASSWORD/$1/g" $JENKINS_HOME/.jenkins/basic-security-$SALT.groovy

LOCAL_PASSWORD="$(get-admin-password)"

execute-groovy-script "${LOCAL_PASSWORD:-"nopassword"}" "$JENKINS_HOME/.jenkins/basic-security-$SALT.groovy" ${@:2}

if [[ "0" == "$?" ]]; then
  echo "Jenkins admin password changed to : $1"

  echo "Reporting new password ($1) in local storage ..."

  echo "$1" > "$JENKINS_HOME/.jenkins/auth"

  remove_temporary_files "$JENKINS_HOME/.jenkins/basic-security-$SALT.groovy"
else
  remove_temporary_files "$JENKINS_HOME/.jenkins/basic-security-$SALT.groovy"

  echo "Errors changing admin password via Jenkins client!!"
fi
