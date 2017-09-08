#!/bin/bash

DAEMON_COMMAND="-daemon"
#Check Jenkins come up and running ...
function checkJenkinsIsUp {
  COUNTER=0
  echo "Waiting for Jenkins to be up and running ..."
  JENKINS_UP="$(curl -I  --stderr /dev/null http://localhost:8080/cli/ | head -1 | cut -d' ' -f2)"
  while [[ "200" != "$JENKINS_UP" && $COUNTER -lt 60 ]]
  do
    sleep 10
    echo "Waiting for Jenkins to be up and running ..."
    JENKINS_UP="$(curl -I  --stderr /dev/null http://localhost:8080/cli/ | head -1 | cut -d' ' -f2)"
    let COUNTER=COUNTER+1
  done
}

mkdir -p "$JENKINS_HOME/.jenkins"

PLUGINS_CODE="1"

if ! [[ -e $JENKINS_HOME/.jenkins/auth ]]; then

  sudo chown -Rf jenkins:jenkins $JENKINS_HOME
  sudo chown -Rf jenkins:jenkins $JENKINS_BIN_HOME
  sudo chown -Rf jenkins:jenkins /jenkins

  mkdir -p "$JENKINS_HOME/workflow-libs"

  sed -i "s/JENKINS_ADMIN_PASSWORD/$JENKINS_ADMIN_PASSWORD/g" $JENKINS_BIN_HOME/ref/init.groovy.d/basic-security.groovy
  sed -i "s/NUMBER_OF_JENKINS_EXECUTORS/$NUMBER_OF_JENKINS_EXECUTORS/g" $JENKINS_BIN_HOME/ref/init.groovy.d/executors.groovy
fi

if ! [[ -e $JENKINS_HOME/.ssh ]]; then
  echo "Creating Jenkins default ssh keys ..."
  mkdir -p $JENKINS_HOME/.ssh
  tar -xzf /jenkins/jenkins-ssh.tgz -C $JENKINS_HOME/.ssh
  rm -Rf /jenkins/jenkins-ssh.tgz
  if [[ -e $JENKINS_HOME/.ssh/id_rsa ]]; then
    chmod 600 $JENKINS_HOME/.ssh/id_rsa
  fi
  echo "Default SSH keys : "
  ls $JENKINS_HOME/.ssh/
  if ! [[ -z "$GIT_USER_NAME" ]]; then
    git config --global user.name "$GIT_USER_NAME"
  fi
  if ! [[ -z "$GIT_USER_EMAIL" ]]; then
    git config --global user.email "$GIT_USER_EMAIL"
  fi
fi

if ! [[ -e $JENKINS_HOME/.jenkins/maven ]]; then
#  /usr/share/maven/conf/settings.xml.template
  if ! [[ -z "$NEXUS_USER" || -z "$NEXUS_PASSWORD" || -z "$NEXUS_SNAPSHOT_REPO_URL" || -z "$NEXUS_RELEASE_REPO_URL" ]]; then
    echo -e "Configuring Nexus in local Maven ...\nUser: $NEXUS_USER\nPassword: $NEXUS_PASSWORD\nSnapshot Repo: $NEXUS_SNAPSHOT_REPO_URL\nRelease Repo: $NEXUS_RELEASE_REPO_URL"
    sudo cp /usr/share/maven/conf/settings.xml.template /usr/share/maven/conf/settings.xml
    sudo sed -i "s/REPOUSER/$NEXUS_USER/g" /usr/share/maven/conf/settings.xml
    sudo sed -i "s/REPOPASSWORD/$NEXUS_PASSWORD/g" /usr/share/maven/conf/settings.xml
    sudo sed -i "s/SNAPSHOTREPO/$(echo $NEXUS_SNAPSHOT_REPO_URL|sed "s/\//\\\\\//g")/g" /usr/share/maven/conf/settings.xml
    sudo sed -i "s/RELEASEREPO/$(echo $NEXUS_RELEASE_REPO_URL|sed "s/\//\\\\\//g")/g" /usr/share/maven/conf/settings.xml
  else
    echo "One or more Nexus parmeters are missing, no maven configuration allowed here ..."
  fi
  touch $JENKINS_HOME/.jenkins/maven
fi

start-jenkins

if ! [[ -e $JENKINS_HOME/.jenkins/auth ]]; then
  echo "Changing local reference for initial password ..."
    echo "$JENKINS_ADMIN_PASSWORD" > $JENKINS_HOME/.jenkins/auth

    echo "Jenkins admin password is : $JENKINS_ADMIN_PASSWORD"

    #execute-groovy-script "$(get-admin-password)" $JENKINS_BIN_HOME/ref/init.groovy.d/jenkins-seed-job.groovy
fi


PLUGINS_CODE="1"
if ! [[ -e $JENKINS_HOME/.jenkins/plugins.txt ]]; then
  checkJenkinsIsUp
  if ! [[ -z "$PLUGINS_FILE_URL" ]]; then
    install-jenkins-plugins "$PLUGINS_FILE_URL" "$PLUGINS_CONFIG_FILES_TAR_GZ_URL"
    PLUGINS_CODE="$?"
  fi
  if [[ "0" != "$PLUGINS_CODE" ]]; then
    echo "Installing default plugins ..."
    echo "$(cat $JENKINS_HOME/default-plugins.txt | awk 'BEGIN {FS=OFS="^M"}{print $1" "}' | xargs echo "install-plugins.sh")" > $JENKINS_HOME/install-plugins.sh
    chmod 777 $JENKINS_HOME/install-plugins.sh
    bash -c $JENKINS_HOME/install-plugins.sh
    RESPONSE="$?"
    rm -f $JENKINS_HOME/install-plugins.sh
    if [[ "0" == "$RESPONSE" ]]; then
      #success
      cp /var/jenkins_home/default-plugins.txt $JENKINS_HOME/.jenkins/plugins.txt
      echo "Plugins installation successful!!"
      echo "Restarting Jenkins ..."
      if [[ "running" == "$(status-jenkins)" ]]; then
        terminate-jenkins
      fi
      start-jenkins
      echo "Jenkins Restarted"
    else
      echo "Errors occurred during plugins installation!!"
    fi
  else
    echo "Restarting Jenkins ..."
    if [[ "running" == "$(status-jenkins)" ]]; then
      terminate-jenkins
    fi
    start-jenkins
    echo "Jenkins Restarted"
  fi
fi

echo "*************************************************************************"
echo "Available custom Jenkins Server Commands : "
echo "*************************************************************************"
echo "start-jenkins                                        Start Jenkins Server"
echo "restart-jenkins           admin-passwd             Restart Jenkins Server"
echo "status-jenkins                                   Status of Jenkins Server"
echo "stop-jenkins              admin-passwd                Stop Jenkins Server"
echo "stop-safe-jenkins         admin-passwd         Stop Safely Jenkins Server"
echo "terminate-jenkins                        Terminate Jenkins Server process"
echo "jenkins-logs                                     Tail Jenkins Server logs"
echo "install-jenkins-plugins   file-url           Download and install Plugins"
echo "execute-cli-file          passwd file cmd..Execute command using file cnt"
echo "execute-groovy-script     passwd file arg.. Execute groovy using file cnt"
echo "execute-cli-command       passwd cmd..            Execute command via api"
echo "change-admin-password     passwd   Change and store locally new admin pwd"
echo "get-admin-password                   Retrieve local stored admin password"
echo "*************************************************************************"
echo ""
echo ""
LOCAL_PASSWORD="$(get-admin-password)"
echo "*************************************************************************"
echo "Administration (admin) password :  \"${LOCAL_PASSWORD:-"<none>"}\""
echo "*************************************************************************"
echo ""
echo ""

install-jenkins-projects

if [[ "" != "$(echo "$@" | grep "\\$DAEMON_COMMAND")" ]]; then

  jenkins-logs

  echo "Entering in sleep mode!!"
  tail -f /dev/null

elif [[ $# -gt 1 ]]; then
  echo "Executing command :  ${@:1:${#}}"
  exec  ${@:1:${#}}
else
  echo "Nothing to do, quitting ..."
fi