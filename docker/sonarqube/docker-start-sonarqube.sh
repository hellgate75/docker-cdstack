#!/bin/bash
DAEMON_COMMAND="-daemon"

dump-env

echo "Waiting for database to be up ..."
echo "Timeout: $STARTUP_TIMEOUT_SECONDS s"

sleep "$STARTUP_TIMEOUT_SECONDS"

if [[ "0" != "$SONARQUBE_REINSTALL_PLUGIN" ]]; then
  rm -f $SONARQUBE_STAGING_FOLDER/plugins.txt
fi

install-plugins-sonarqube

service sonarqube start

if [[ "" != "$(echo "$@" | grep "\\$DAEMON_COMMAND")" ]]; then
  echo "Entering in sleep mode!!"
  tail -f /dev/null
elif [[ $# -gt 1 ]]; then
  echo "Executing command :  ${@:1:${#}}"
  exec  ${@:1:${#}}
else
  echo "Nothing to do, quitting ..."
fi

export STARTUP_TIMEOUT_SECONDS=5
