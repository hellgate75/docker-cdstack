#!/bin/bash

DAEMON_COMMAND="-daemon"


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

  nohup bash -c "nexus run &> $NEXUS_DATA/log/nexus.log" &

else
  echo "Nexus3 OSS Server is running"
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
