#!/bin/bash
if ! [[ -e $JENKINS_HOME/.jenkins/maven ]]; then
#  /usr/share/maven/conf/settings.xml.template
  if ! [[ -z "$NEXUS_USER" || -z "$NEXUS_PASSWORD" || -z "$NEXUS_SNAPSHOT_REPO_URL" || -z "$NEXUS_RELEASE_REPO_URL" ]]; then
    echo -e "Configuring Nexus in local Maven ...\nUser: $NEXUS_USER\nPassword: $NEXUS_PASSWORD\nSnapshot Repo: $NEXUS_SNAPSHOT_REPO_URL\nRelease Repo: $NEXUS_RELEASE_REPO_URL"
    sudo cp /usr/share/maven/conf/settings.xml.template /usr/share/maven/conf/settings.xml.new
    sudo sed -i "s/REPOUSER/$NEXUS_USER/g" /usr/share/maven/conf/settings.xml.new
    sudo sed -i "s/REPOPASSWORD/$NEXUS_PASSWORD/g" /usr/share/maven/conf/settings.xml.new
    sudo sed -i "s/SNAPSHOTREPO/$(echo $NEXUS_SNAPSHOT_REPO_URL|sed "s/\//\\\\\//g")/g" /usr/share/maven/conf/settings.xml.new
    sudo sed -i "s/RELEASEREPO/$(echo $NEXUS_RELEASE_REPO_URL|sed "s/\//\\\\\//g")/g" /usr/share/maven/conf/settings.xml.new
    sudo cp /usr/share/maven/conf/settings.xml /usr/share/maven/conf/settings.xml.ori
    sudo cp /usr/share/maven/conf/settings.xml.new /usr/share/maven/conf/settings.xml
  else
    echo "One or more Nexus parmeters are missing, no maven configuration allowed here ..."
  fi
  touch $JENKINS_HOME/.jenkins/maven
else
  echo "INFO: Maven has been already configured and this Jenkins Node!!"
fi
exit 0
