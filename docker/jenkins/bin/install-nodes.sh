#!/bin/bash
JENKINS_STAGING_FOLDER="$JENKINS_HOME/.jenkins"
JENKINS_AGENT_LIST_FILE="$JENKINS_STAGING_FOLDER/node-list.txt"

function download_file() {
  if ! [[ -z "$(echo $2|grep -i 'https://')" ]]; then
    curl -sSL -o $1 $2
    return "$?"
  else
    curl -L -o $1 $2
    return "$?"
  fi
}

if ! [[ -z "$JENKINS_NODE_LIST_URL" ]]; then
  touch $JENKINS_AGENT_LIST_FILE
  chmod 666 $JENKINS_AGENT_LIST_FILE
  download_file "$JENKINS_AGENT_LIST_FILE" "$JENKINS_NODE_LIST_URL"
  if ! [[ -z "$(cat $JENKINS_AGENT_LIST_FILE)" ]]; then
    echo "Installing Node Agents from Node Agent list file : $JENKINS_AGENT_LIST_FILE"
    cat $JENKINS_AGENT_LIST_FILE|while read line; do
       COMMAND="$(echo "configure-agent-node $line"| sed 's/|/ /g')"
       echo "Executing Node Agent creation : $COMMAND"
       bash -c "$COMMAND"
       echo "Response: $?"
    done
    exit 0
  else
    echo "WARNING: Node Agent list file from URL : $JENKINS_NODE_LIST_URL seems empty!!"
  fi
  echo "WARNING: Some problems occurred downloading Node Agent list file : $JENKINS_NODE_LIST_URL"
else
  echo "***************************************************"
  echo "*** Warning no Agent Node list file specified!! ***"
  echo "***************************************************"
fi
exit 1
