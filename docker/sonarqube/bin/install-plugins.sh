#!/bin/bash

SONARQUBE_STAGING_FOLDER="/root/.sonarqube"
INSTALL_FOLDER="/opt/sonarqube/extensions/plugins"
ARCHIVES_FOLDER="$SONARQUBE_STAGING_FOLDER/archives"
ARCHIVES_BUILD_FOLDER="$SONARQUBE_STAGING_FOLDER/workspaces"

function download_file() {
  if [[ -z "$(echo $2|grep -i 'https://')" ]]; then
    curl -L -o $1 $2
    return "$?"
  else
    curl -sSL -o $1 $2
    return "$?"
  fi
}

function get_file_name() {
  echo $1 | awk 'BEGIN {FS = OFS = "/"} {print $NF}' | xargs echo | grep '.'
}

function get_file_extension() {
  echo "$(get_file_name $1)" | awk 'BEGIN {FS = OFS = "."} {print $NF}' | xargs echo
}

function download_unzip_maven_build() {
  download_file "$ARCHIVES_FOLDER/$1" "$2"
}

function download_untar_maven_build() {
  download_file "$ARCHIVES_FOLDER/$1" "$2"
}


if ! [[ -z "$PLUGINS_FILE_URL" ]]; then
  echo "Downloading plugins from URL : $PLUGINS_FILE_URL"
  mkdir -p $SONARQUBE_STAGING_FOLDER
  mkdir -p "$ARCHIVES_FOLDER"
  touch $SONARQUBE_STAGING_FOLDER/plugins.txt
  chmod 666 $SONARQUBE_STAGING_FOLDER/plugins.txt
  download_file "/root/.sonarqube/plugins.txt" "$PLUGINS_FILE_URL"
  if ! [[ -z "$(cat /root/.sonarqube/plugins.txt)" ]]; then
    UNTOUCHED=1
    NEXT="0"
    cat /root/.sonarqube/plugins.txt | \
    while read PLUGIN; do
      IFS="|"; for TOKEN in $PLUGIN; do
      if ! [[ -z "$(echo $TOKEN | grep install)" ]]; then
        echo "INSTALL PLUGIN :"
        NEXT="1"
        #download file
      elif ! [[  -z "$(echo $TOKEN | grep 'unzip+maven')"  ]]; then
        echo "UNZIP AND INSTALL :"
        NEXT="2"
        #unzip and maven
      elif ! [[  -z "$(echo $TOKEN | grep 'untar+maven')"  ]]; then
        echo "UNTAR AND INSTALL :"
        NEXT="3"
        #untar and maven
      elif  [[  -z "$(echo $TOKEN | grep http)"  ]]; then
        echo "Unknown operation : $TOKEN"
        NEXT="0"
      else
        if [[ "0" != "$NEXT" ]]; then
          FILE_NAME="$(get_file_name $TOKEN)"
          if ! [[ -z "$FILE_NAME" ]]; then
            EXTENSION="$(get_file_extension $TOKEN)"
            if ! [[ -e $INSTALL_FOLDER/$FILE_NAME ]] && ! [[ -e $ARCHIVES_FOLDER/$FILE_NAME ]]; then
              echo "*************************************************************"
              echo "Installing plugin : $FILE_NAME"
              echo "Source URL : $TOKEN"
              if [[ "1" == "$NEXT" ]]; then
                echo "Saving plugin : $FILE_NAME"
                download_file $INSTALL_FOLDER/$FILE_NAME $TOKEN
              elif [[ "2" == "$NEXT" ]]; then
                echo "Unzipping and building plugin : $FILE_NAME"
                download_unzip_maven_build $FILE_NAME $TOKEN
              elif [[ "3" == "$NEXT" ]]; then
                echo "Untarring and building plugin : $FILE_NAME"
                download_untar_maven_build $FILE_NAME $TOKEN
              fi
              UNTOUCHED=0
              echo "*************************************************************"
            else
              echo "Plugin $FILE_NAME already installed, skipping!!"
            fi
          else
            echo "Wrong URL format, no file specified : $TOKEN"
          fi
        else
          echo "Ignoring plugin : $TOKEN"
        fi
      fi
      done
    done
      exit $UNTOUCHED
  fi
  echo "Some problems occurred downloading plugin file : $PLUGINS_FILE_URL"
  exit 1
else
  echo "******************************************"
  echo "*** Warning no plugin file specified!! ***"
  echo "******************************************"
fi
exit 1
