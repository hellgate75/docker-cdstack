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

mkdir -p $JENKINS_HOME/.jenkins

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
    touch $JENKINS_HOME/.jenkins/.ssh_remote
  else
    echo "No remote credential file available!!"
  fi
else
  echo "Remote credentials alredy installed!!"
fi
