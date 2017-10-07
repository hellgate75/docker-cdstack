FROM jenkins/jenkins

MAINTAINER Fabrizio Torelli <hellgate75@gmail.com>

LABEL vendor="Fabrizio Torelli <hellgate75@gmail.com>"
LABEL com.docker.image.license="LGPL License, Version 3.0"
LABEL com.docker.image.name="Jenkins Pipeline Manager base image"
LABEL com.docker.image.type="Jenkins Continuous Delivery Pipeline Manager Image"

ENV JENKINS_BIN_HOME="/usr/share/jenkins" \
    JAVA_MAX_HEAP="2G" \
    JAVA_MIN_HEAP="256m" \
    JENKINS_ADMIN_PASSWORD="jenkins" \
    NUMBER_OF_JENKINS_EXECUTORS="2" \
    PLUGINS_FILE_URL="" \
    PLUGINS_CONFIG_FILES_TAR_GZ_URL="" \
    AGENT_ENVIRONMENT_BASH_SCRIPT_URL="" \
    SSH_KEY_FILES_TAR_GZ_URL="" \
    PROJECT_LIST_FILE_URL="" \
    JENKINS_NODE_LIST_URL="" \
    GIT_USER_NAME="" \
    GIT_USER_EMAIL="" \
    SONARQUBE_URL="" \
    SONARQUBE_APIKEY="" \
    SONARQUBE_USER="" \
    SONARQUBE_PASSWORD="" \
    NEXUS_BASE_REPO_URL="" \
    NEXUS_SNAPSHOT_REPO_URL="" \
    NEXUS_RELEASE_REPO_URL="" \
    NEXUS_STAGING_DOCKER_REPO_URL="" \
    NEXUS_PRODUCTION_DOCKER_REPO_URL="" \
    NEXUS_USER="" \
    NEXUS_PASSWORD="" \
    REF="/usr/share/jenkins/ref/plugins"


USER root

RUN mkdir -p $JENKINS_HOME/.jenkins

RUN apt-get update \
    && apt-get -y install apt-utils \
    && apt-get -y install --no-install-recommends sudo openssl tar groovy unzip monit ca-certificates \
                        openssh-server cron wget curl htop git maven gradle vim net-tools zip locales \
    && apt-get -y upgrade \
    && apt-get -y autoremove \
    && apt-get -y clean \
    && rm -rf /var/lib/apt/lists/*

COPY docker-entrypoint.sh /docker-entrypoint.sh

COPY docker-start-jenkins.sh /docker-start-jenkins.sh

COPY bin/start-jenkins.sh /usr/local/bin/start-jenkins

COPY bin/restart-jenkins.sh /usr/local/bin/restart-jenkins

COPY bin/status-jenkins.sh /usr/local/bin/status-jenkins

COPY bin/stop-jenkins.sh /usr/local/bin/stop-jenkins

COPY bin/stop-safe-jenkins.sh /usr/local/bin/stop-safe-jenkins

COPY bin/terminate-jenkins.sh /usr/local/bin/terminate-jenkins

COPY bin/logs-jenkins.sh /usr/local/bin/jenkins-logs

COPY bin/install-plugins.sh /usr/local/bin/install-jenkins-plugins

COPY bin/install-credentials.sh /usr/local/bin/install-jenkins-credentials

COPY bin/execute-cli-file.sh /usr/local/bin/execute-cli-file

COPY bin/execute-cli-command.sh /usr/local/bin/execute-cli-command

COPY bin/execute-groovy-script.sh /usr/local/bin/execute-groovy-script

COPY bin/change-admin-password.sh /usr/local/bin/change-admin-password

COPY bin/get-admin-password.sh /usr/local/bin/get-admin-password

COPY bin/configure-agent-node.sh /usr/local/bin/configure-agent-node

COPY bin/install-projects.sh /usr/local/bin/install-jenkins-projects

COPY bin/install-nodes.sh /usr/local/bin/install-jenkins-nodes

COPY bin/configure-maven-repos.sh /usr/local/bin/configure-maven

COPY files/default-plugins.txt $JENKINS_HOME/default-plugins.txt

COPY files/jenkins-config.xml  $JENKINS_HOME/config.xml

COPY files/basic-security.groovy $JENKINS_BIN_HOME/ref/init.groovy.d/basic-security.groovy

COPY files/jenkins-seed-jobs.groovy $JENKINS_BIN_HOME/ref/init.groovy.d/jenkins-seed-jobs.groovy

COPY files/executors.groovy $JENKINS_BIN_HOME/ref/init.groovy.d/executors.groovy

COPY files/create-ssh-credentials.groovy $JENKINS_BIN_HOME/ref/init.groovy.d/create-ssh-credentials.groovy

COPY files/add-agent-node.groovy.template $JENKINS_HOME/.jenkins/add-agent-node.groovy.template

COPY files/create-custom-ssh-credentials.groovy.template $JENKINS_HOME/.jenkins/create-custom-ssh-credentials.groovy.template

COPY files/hudson.plugins.git.GitTool.xml $JENKINS_HOME/hudson.plugins.git.GitTool.xml

COPY files/settings.xml /usr/share/maven/conf/settings.xml.template

COPY files/jenkins.CLI.xml $JENKINS_HOME/jenkins.CLI.xml

RUN  echo "Init jenkins super-user ..." && cp /etc/sudoers /root/sudoers \
    && chmod 777 /root/sudoers \
    && echo "jenkins  ALL=(ALL) NOPASSWD:ALL" >> /root/sudoers \
    && chmod 400 /root/sudoers \
    && mv /root/sudoers /etc/sudoers \
    && chmod 777 /docker* \
    && chmod 777 /usr/local/bin/* \
    && mkdir -p /jenkins/projects \
    && touch /usr/share/maven/conf/logging

USER jenkins

WORKDIR $JENKINS_HOME

COPY files/jenkins-ssh.tgz /jenkins/jenkins-ssh.tgz

RUN sudo chown -Rf jenkins:jenkins /jenkins \
    && sudo chown -Rf jenkins:jenkins $JENKINS_HOME

COPY files/project-list.txt /jenkins/project-list.txt

VOLUME ["/var/jenkins_home"]

EXPOSE 8080 50000

CMD /docker-start-jenkins.sh -daemon

ENTRYPOINT "/docker-entrypoint.sh"
