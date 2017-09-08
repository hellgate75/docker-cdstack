#!/bin/bash


function download_file() {
  if ! [[ -z "$(echo $2|grep -i 'https://')" ]]; then
    curl -sSL -o $1 $2
    return "$?"
  else
    curl -L -o $1 $2
    return "$?"
  fi
}

function get_repo_name() {
  echo $1 | awk 'BEGIN {FS = OFS = "/"} {print $NF}' | xargs echo | grep '.' | awk 'BEGIN {FS = OFS = "."} {print $1s}' | xargs echo
}
CHANGE=0

if ! [[ -e $JENKINS_HOME/.jenkins/.projects_remote ]]; then
  if ! [[ -z "$PROJECT_LIST_FILE_URL" ]]; then
    download_file "/jenkins/remote-project-list.txt" "$PROJECT_LIST_FILE_URL"
    if [[ -e /jenkins/remote-project-list.txt ]]; then
      echo "Installing project list file from URL : $PROJECT_LIST_FILE_URL"
      mv /jenkins/remote-project-list.txt /jenkins/project-list.txt
      echo "Operation completed!!"
    fi
    touch $JENKINS_HOME/.jenkins/.projects_remote
  fi
fi
PWD=$(pwd)
if ! [[ -e $JENKINS_HOME/.jenkins/.projects ]]; then
  LIST=$(cat /jenkins/project-list.txt | awk 'BEGIN {FS=OFS=" "}{print $1}')
  for project in $LIST; do
    REPOSITORY=""
    IFS="|";for prjToken in $project; do
      if [[ -z "$REPOSITORY" ]]; then
        REPOSITORY="$prjToken"
      else
        cd "$JENKINS_HOME/jobs"
        echo "Repository : $REPOSITORY"
  			echo "Extracting branch: $prjToken"
  			NAME="$(get_repo_name $REPOSITORY)"
        if ! [[ -e "$2/$NAME-$prjToken" ]]; then
          echo "Cloning repository : $REPOSITORY ..."
          git clone "$REPOSITORY" "$JENKINS_HOME/jobs/$NAME-$prjToken"
          if [[ -e "$JENKINS_HOME/jobs/$NAME-$prjToken" ]]; then
            CHANGE=1
      			if [[ "master" != "$prjToken" ]]; then
              echo "Pulling branch : $prjToken ..."
      				cd "$JENKINS_HOME/jobs/$NAME-$prjToken"
      				git fetch
      				git checkout "$prjToken"
            else
              CHANGE=1
  						echo "Repository already on master branch!!"
      			fi
          else
            echo "Problems cloning repository : $REPOSITORY - at branch : $prjToken"
          fi
        else
          echo "Repository : $REPOSITORY exists, updating branch : $prjToken ..."
  				cd "$JENKINS_HOME/jobs/$NAME-$prjToken"
  				git pull
          CHANGE=1
        fi
        sleep 20
      fi
    done
  done
  touch $JENKINS_HOME/.jenkins/.projects
fi

if [[ "0" != "$CHANGE" ]]; then
  echo "Restarting Jenkins ..."
  restart-jenkins
fi
