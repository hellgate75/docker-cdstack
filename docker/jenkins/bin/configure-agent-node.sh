#!/bin/bash

if [[ $# -lt 4 ]]; then
  echo "configure-agent-node agent-name agent-host agent-ssh-user agent-ssh-password [agent-ssh-port]"
  exit 1
fi
AGENT_NAME="$1"
AGENT_HOST="$2"
AGENT_USER="$3"
AGENT_PASSWORD="$4"
AGENT_PORT="${5:-"22"}"

SALT="$(date "+%s")"
AGENT_ENVIRONMENT_SCRIPT_FILE="$JENKINS_HOME/.jenkins/agent-environment.sh"
AGENT_GRROVY_TEMPLATE_FILE="$JENKINS_HOME/.jenkins/add-agent-node.groovy.template"
AGENT_GRROVY_SCRIPT_FILE="$JENKINS_HOME/.jenkins/add-agent-node-$SALT.groovy"

function download_file() {
  if [[ -z "$(echo $2|grep -i 'https://')" ]]; then
    curl -sSL -o $1 $2
    return "$?"
  else
    curl -L -o $1 $2
    return "$?"
  fi
}

if ! [[ -z "$AGENT_ENVIRONMENT_BASH_SCRIPT_URL" ]]; then
  if ! [[ -e "$AGENT_ENVIRONMENT_SCRIPT_FILE" ]]; then
    download_file "$AGENT_ENVIRONMENT_SCRIPT_FILE" "$AGENT_ENVIRONMENT_BASH_SCRIPT_URL"
    if [[ "0" == "$?" ]]; then
      #Success
      if ! [[ -z "$(cat $AGENT_ENVIRONMENT_SCRIPT_FILE)" ]]; then
        #Not empty
        echo "SUCCESS: Downloaded agent environment script from : $AGENT_ENVIRONMENT_BASH_SCRIPT_URL!!"
        chmod 777 "$AGENT_ENVIRONMENT_SCRIPT_FILE"
      else
        echo "ERROR: Aagent environment script is empty!!"
        exit 1
      fi
    else
      #Failure
      echo "ERROR: Problem downloading agent environment script from : $AGENT_ENVIRONMENT_BASH_SCRIPT_URL!!"
      exit 1
    fi
  else
    echo "INFO: Agent environment script found at : $AGENT_ENVIRONMENT_SCRIPT_FILE!!"
    exit 1
  fi
else
  echo "WARNING: No agent environment script URL defined!!"
  exit 1
fi

if [[ -e $AGENT_ENVIRONMENT_SCRIPT_FILE ]]; then
  if ! [[ -e "$AGENT_GRROVY_TEMPLATE_FILE" ]]; then
    echo "ERROR: Unable to find grrovy agent template class at : $AGENT_GRROVY_TEMPLATE_FILE"
    exit 1
  fi
  echo "Configuring agent : $AGENT_NAME"
  copy "$AGENT_GRROVY_TEMPLATE_FILE" "$AGENT_GRROVY_SCRIPT_FILE"
  chmod 766 "$AGENT_GRROVY_SCRIPT_FILE"
  sed -i "s/agent_host/$AGENT_HOST/g" "$AGENT_GRROVY_SCRIPT_FILE"
  sed -i "s/agent_node_label/$AGENT_NAME/g" "$AGENT_GRROVY_SCRIPT_FILE"
  sed -i "s/agent_user/$AGENT_USER/g" "$AGENT_GRROVY_SCRIPT_FILE"
  sed -i "s/agent_password/$AGENT_PASSWORD/g" "$AGENT_GRROVY_SCRIPT_FILE"
  ##Complete all environment variables substitutution
  source $AGENT_ENVIRONMENT_SCRIPT_FILE
  execute-groovy-script "$(get-admin-password)" "$AGENT_GRROVY_SCRIPT_FILE"
  if [[ "0" == "$?" ]]; then
    echo "SUCCESS: Agent Node $AGENT_NAME created!!"
  else
    echo "ERROR: Agent Node $AGENT_NAME creation failed!!"
  fi
fi
