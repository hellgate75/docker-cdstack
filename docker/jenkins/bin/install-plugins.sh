#!/bin/bash

if [[ $# -lt 1 ]]; then
  echo "install-plugins plugin-file-url [plugin-config-file-tar-gz-url]"
  exit 1
fi

JENKINS_STAGING_FOLDER="$JENKINS_HOME/.jenkins"
JENKINS_PLUGINS_FILE="$JENKINS_STAGING_FOLDER/plugins.txt"
JENKINS_PLUGIN_CONFIG_FILE="$JENKINS_STAGING_FOLDER/plugins-config.tgz"
JENKINS_PLUGINS_URL="$1"
JENKINS_PLUGINS_TGZ_URL="$2"

function download_file() {
  if ! [[ -z "$(echo $2|grep -i 'https://')" ]]; then
    curl -sSL -o $1 $2
    return "$?"
  else
    curl -L -o $1 $2
    return "$?"
  fi
}

if ! [[ -z "$JENKINS_PLUGINS_URL" ]]; then
  mkdir -p $JENKINS_STAGING_FOLDER
  touch $JENKINS_STAGING_FOLDER/plugins.txt
  chmod 666 $JENKINS_STAGING_FOLDER/plugins.txt
  download_file "$JENKINS_PLUGINS_FILE" "$JENKINS_PLUGINS_URL"
  if ! [[ -z "$(cat $JENKINS_PLUGINS_FILE)" ]]; then
    echo "Installing plugins from plugin file : $JENKINS_PLUGINS_URL"
    echo "$(cat $JENKINS_STAGING_FOLDER/plugins.txt | awk 'BEGIN {FS=OFS="^M"}{print $1" "}' | xargs echo "install-plugins.sh")" > $JENKINS_HOME/install-plugins.sh
    chmod 777 $JENKINS_HOME/install-plugins.sh
    bash -c $JENKINS_HOME/install-plugins.sh
    RESPONSE="$?"
    rm -f $JENKINS_HOME/install-plugins.sh
    if [[ "0" == "$RESPONSE" ]]; then
      #success
      echo "SUCCESS: Plugins installation successful!!"
      if ! [[ -z "$JENKINS_PLUGINS_TGZ_URL" ]]; then
        echo "Download Plugins configuration archive from URL : $JENKINS_PLUGINS_TGZ_URL ..."
        download_file "$JENKINS_PLUGIN_CONFIG_FILE" "$JENKINS_PLUGINS_TGZ_URL"
        if [[ "0" == "$?" ]]; then
          if [[ -e $JENKINS_PLUGIN_CONFIG_FILE ]]; then
            tar -xzf $JENKINS_PLUGIN_CONFIG_FILE -C $JENKINS_HOME
            echo "SUCCESS: Plugins configuration archive files extracted in folder $JENKINS_HOME!!"
          else
            echo "ERROR: Problems retriving Plugins configuration archive file on disk!!"
          fi
        else
          echo "ERROR: Problems downloading Plugins configuration achive from $JENKINS_PLUGINS_TGZ_URL !!"
        fi
      else
        echo "**************************************************"
        echo "*** Warning no plugin archive file specified!! ***"
        echo "**************************************************"
      fi
      exit 0
    fi
    echo "ERROR: Errors occurred during plugins installation!!"
  else
    echo "WARNING: Plugin file from URL : $JENKINS_PLUGINS_URL seems empty!!"
  fi
  echo "WARNING: Some problems occurred downloading plugin file : $JENKINS_PLUGINS_URL"
else
  echo "******************************************"
  echo "*** Warning no plugin file specified!! ***"
  echo "******************************************"
fi
exit 1
