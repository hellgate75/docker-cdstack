#!/bin/bash

if [[ $# -lt 5 ]]; then
  echo "configure-agent-node agent-name agent-host num-executors agent-ssh-user agent-ssh-password [agent-ssh-port]"
  exit 1
fi
AGENT_NAME="$1"
AGENT_HOST="$2"
AGENT_EXECUTORS="$3"
AGENT_USER="$4"
AGENT_PASSWORD="$5"
AGENT_PORT="${5:-"22"}"

SALT="$(date "+%s")"
AGENT_ENVIRONMENT_SCRIPT_FILE="$JENKINS_HOME/.jenkins/agent-environment.sh"
AGENT_GROOVY_TEMPLATE_FILE="$JENKINS_HOME/.jenkins/add-agent-node.groovy.template"
AGENT_GROOVY_SCRIPT_FILE="$JENKINS_HOME/.jenkins/add-agent-node-$SALT.groovy"

function download_file() {
  if ! [[ -z "$(echo $2|grep -i 'https://')" ]]; then
    curl -sSL -o $1 $2
    return "$?"
  else
    curl -L -o $1 $2
    return "$?"
  fi
}

function sanitize() {
  echo "$(echo $1|sed -e "s/\\\:/\\\\\:/g")"
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
fi

if [[ -e $AGENT_ENVIRONMENT_SCRIPT_FILE ]]; then
  source $AGENT_ENVIRONMENT_SCRIPT_FILE
fi
if ! [[ -e "$AGENT_GROOVY_TEMPLATE_FILE" ]]; then
  echo "ERROR: Unable to find groovy agent template class at : $AGENT_GROOVY_TEMPLATE_FILE"
  exit 1
fi
##Complete all environment variables substitutution
echo "Configuring agent : $AGENT_NAME"
cp "$AGENT_GROOVY_TEMPLATE_FILE" "$AGENT_GROOVY_SCRIPT_FILE"
chmod 766 "$AGENT_GROOVY_SCRIPT_FILE"
sed -i "s/agent_host/$(sanitize $AGENT_HOST)/g" $AGENT_GROOVY_SCRIPT_FILE
sed -i "s/agent_node_label/$(sanitize $AGENT_NAME)/g" $AGENT_GROOVY_SCRIPT_FILE
sed -i "s/agent_user/$(sanitize $AGENT_USER)/g" $AGENT_GROOVY_SCRIPT_FILE
sed -i "s/agent_password/$(sanitize $AGENT_PASSWORD)/g" $AGENT_GROOVY_SCRIPT_FILE
sed -i "s/num_executors/$(sanitize $AGENT_EXECUTORS)/g" $AGENT_GROOVY_SCRIPT_FILE


execute-groovy-script "$(get-admin-password)" "$AGENT_GROOVY_SCRIPT_FILE"
if [[ "0" == "$?" ]]; then
  echo "SUCCESS: Agent Node $AGENT_NAME created!!"
else
  echo "ERROR: Agent Node $AGENT_NAME creation failed!!"
fi
