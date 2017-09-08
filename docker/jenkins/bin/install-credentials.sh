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

if [[ "--help" == "$1" ]]; then
  echo "install-jenkins-credentials [--help|--force]"
  echo "   --help   Show Current help"
  echo "   --force  Foce Credential donwload and install"
  exit 0
fi

if [[ "--force" == "$1" ]]; then
  rm -f $JENKINS_HOME/.jenkins/.ssh_remote
fi


if ! [[ -e $JENKINS_HOME/.jenkins/.ssh_remote ]]; then
  if ! [[ -z "$SSH_KEY_FILES_TAR_GZ_URL" ]]; then
    download_file "/jenkins/remote-jenkins-ssh.tgz" "$SSH_KEY_FILES_TAR_GZ_URL"
    if [[ -e /jenkins/remote-jenkins-ssh.tgz ]]; then
      echo "Installing new keys from archive, via URL : $SSH_KEY_FILES_TAR_GZ_URL"
      tar -xzf /jenkins/remote-jenkins-ssh.tgz -C $JENKINS_HOME/.ssh
      rm -f /jenkins/remote-jenkins-ssh.tgz
      if [[ -e $JENKINS_HOME/.ssh/id_rsa ]]; then
        chmod 600 $JENKINS_HOME/.ssh/id_rsa*
      fi
      echo "Remote SSH files : "
      ls $JENKINS_HOME/.ssh/
      echo "Operation completed!!"
    fi
    for i in $(ls $JENKINS_HOME/.ssh/); do
      if ! [[ -z "$(echo $i|grep id_rsa_|grep -v pub)"  ]]; then
        NAME="$(echo $i|awk 'BEGIN {FS=OFS="id_rsa_"}{print $2}')"
        if ! [[ -e $JENKINS_HOME/.jenkins/.ssh_keys_$NAME ]]; then
          echo "Installing key : $NAME"
          echo "Jenkins Security ssh Credential : ssh_credential_$NAME"
          SALT="$(date "+%s")"
          cp -f $JENKINS_HOME/.jenkins/create-custom-ssh-credentials.groovy.template $JENKINS_BIN_HOME/ref/init.groovy.d/create-custom-ssh-credentials-$SALT.groovy
          sed -i "s/CREDENTIALS_KEYFILE_PATH/$JENKINS_HOME\\\/.ssh\\\/id_rsa_$NAME/g" $JENKINS_BIN_HOME/ref/init.groovy.d/create-custom-ssh-credentials-$SALT.groovy
          sed -i "s/CREDENTIALS_NAME/ssh_credential_$NAME/g" $JENKINS_BIN_HOME/ref/init.groovy.d/create-custom-ssh-credentials-$SALT.groovy
          sed -i "s/CREDENTIALS_USER/$(whoami)/g" $JENKINS_BIN_HOME/ref/init.groovy.d/create-custom-ssh-credentials-$SALT.groovy
          touch $JENKINS_HOME/.jenkins/.ssh_keys_$NAME
        else
          echo "Jenkins Security Key : $NAME already installed"
        fi
      fi
    done
    touch $JENKINS_HOME/.jenkins/.ssh_remote
  else
    echo "No remote credential file available!!"
  fi
else
  echo "Remote credentials alredy installed!!"
fi
