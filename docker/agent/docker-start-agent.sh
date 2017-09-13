#!/bin/bash

DAEMON_COMMAND="-daemon"

FIRST_RUN="0"

if ! [[ -e $JENKINS_HOME/.ssh ]]; then
  FIRST_RUN="1"
  echo "Creating Jenkins default ssh keys ..."
  mkdir -p $JENKINS_HOME/.ssh
  tar -xzf $JENKINS_HOME/jenkins-ssh.tgz -C $JENKINS_HOME/.ssh
  rm -Rf $JENKINS_HOME/jenkins-ssh.tgz
  if [[ -e $JENKINS_HOME/.ssh/id_rsa ]]; then
    chmod 600 $JENKINS_HOME/.ssh/id_rsa
  fi
  echo "Default SSH keys : "
  ls $JENKINS_HOME/.ssh/
else
  echo "Jenkins default ssh keys already installed ..."
fi

install-credentials

chmod 600 $JENKINS_HOME/.ssh/id_rsa
cat $JENKINS_HOME/.ssh/id_rsa.pub > $JENKINS_HOME/.ssh/authorized_keys

mkdir -p $JENKINS_HOME/.jenkins

if ! [[ -e $JENKINS_HOME/.jenkins/git_cred ]]; then
  if ! [[ -z "$GIT_USER_NAME" ]]; then
    git config --global user.name "$GIT_USER_NAME"
  fi
  if ! [[ -z "$GIT_USER_EMAIL" ]]; then
    git config --global user.email "$GIT_USER_EMAIL"
  fi
  touch $JENKINS_HOME/.jenkins/git_cred
fi

if [[ -z "$(ps -eaf|grep dockerd|grep -v grep)" ]]; then
  sudo rm -f /var/run/docker*.pid
  sudo service docker start
  sudo chmod 666 /var/run/docker.sock
  #sudo custom-start-docker
else
  echo "Docker daemon is running"
fi

if [[ -z "$(sudo service ssh status | grep -v "not")" ]]; then
  sudo rm -f /var/run/ssh.pid
  sudo service ssh start
else
  echo "SSH Server is running"
fi

echo ""
echo "*************************************"
echo "Maven version :"
echo "$(mvn --version)"
echo "*************************************"
echo "Java version :"
echo "$(java -version)"
echo "*************************************"
echo "Java version :"
echo "$(groovy --version)"
echo "*************************************"
echo "Scala version :"
echo "$(scala -version)"
echo "*************************************"
echo "Node.js version :"
echo "$(node --version)"
echo "*************************************"
echo "R version :"
echo "$(R --version)"
echo "*************************************"
echo "Python version :"
echo "$(python --version)"
echo "*************************************"
echo "Python PIP version :"
echo "$(pip --version)"
echo "*************************************"
echo "Ruby version :"
echo "$(ruby --version)"
echo "*************************************"
echo "Docker version :"
echo "$(docker version)"
echo "*************************************"
echo "Docker Compose version :"
echo "$(docker-compose version)"
echo "*************************************"
echo "Go language version :"
echo "$(go version)"
echo "*************************************"
echo ""

if [[ "" != "$(echo "$@" | grep "\\$DAEMON_COMMAND")" ]]; then

  tail -f /var/log/docker.log
  echo "Entering in sleep mode!!"
  tail -f /dev/null

elif [[ $# -gt 1 ]]; then
  echo "Executing command :  ${@:1:${#}}"
  exec  ${@:1:${#}}
else
  echo "Nothing to do, quitting ..."
fi
