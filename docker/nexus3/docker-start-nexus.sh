#!/bin/bash

DAEMON_COMMAND="-daemon"

sudo chown -Rf nexus:nexus $NEXUS_DATA

if [[ -z "$(nexus status | grep 'running')" ]]; then

  mkdir -p $NEXUS_HOME/.nexus

  if ! [[ -z "$JVM_MAX_MEM" ]]; then
    sudo sed -i "s/-XX:MaxDirectMemorySize=.*/-XX:MaxDirectMemorySize=$JVM_MAX_MEM/g" $NEXUS_HOME/bin/nexus.vmoptions
  fi
  if ! [[ -z "$JVM_MAX_HEAP" ]]; then
    sudo sed -i "s/-Xmx.*/-Xmx$JVM_MAX_HEAP/g" $NEXUS_HOME/bin/nexus.vmoptions
  fi
  if ! [[ -z "$JVM_MIN_HEAM" ]]; then
    sudo sed -i "s/-Xms.*/-Xms$JVM_MIN_HEAP/g" $NEXUS_HOME/bin/nexus.vmoptions
  fi

  bash -c "cd /opt/sonatype/nexus && bin/nexus run &> $NEXUS_DATA/log/nexus.log" &
  if [[ -z "$(nexus status | grep 'running')" ]]; then
    echo "Nexus3 OSS Server is NOW running!!"
  else
    echo "Nexus3 OSS Server is NOT running!!"
  fi

else
  echo "Nexus3 OSS Server was already running"
fi

if [[ "" != "$(echo "$@" | grep "\\$DAEMON_COMMAND")" ]]; then

  tail -f $NEXUS_DATA/log/nexus.log

  echo "Entering in sleep mode!!"
  tail -f /dev/null

elif [[ $# -gt 1 ]]; then
  echo "Executing command :  ${@:1:${#}}"
  exec  ${@:1:${#}}
else
  echo "Nothing to do, quitting ..."
fi
