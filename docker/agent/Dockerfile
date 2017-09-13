FROM ubuntu:16.10

ENV JENKINS_HOME=/home/jenkins \
    SSH_KEY_FILES_TAR_GZ_URL="" \
    GIT_USER_NAME="" \
    GIT_USER_EMAIL="" \
    DEBIAN_FRONTEND=noninteractive \
    SCALA_HOME=/usr/local/share/scala \
    PATH=$PATH:/usr/local/share/scala/bin:/usr/local/bin:/usr/local/go/bin \
    SCALA_VERSION="2.12.2" \
    NODEJS_VERSION="8.x" \
    JAVA_VERSION="8" \
    ORACLE_LICENSE_VERSION="1-1" \
    GOPATH=/home/jenkins/go \
    GO_VERSION="1.9" \
    GO_OS="linux" \
    GO_ARCH="amd64" \
    DOCKER_COMPOSE_VERSION="1.16.1" \
    DOCKER_DAEMON_ARGS="--experimental" \
    LOG="file"


USER root

WORKDIR /root

RUN apt-get update \
    && apt-get --no-install-recommends --allow-unauthenticated  install -qqy vim curl wget git \
                                   unzip python python-pip python-setuptools python-software-properties python3 python3-pip locales \
                                   python3-setuptools python3-software-properties software-properties-common groovy net-tools \
                                   build-essential python-software-properties openssh-server openssl sudo maven ruby-full \
                                   ca-certificates lxc iptables \
    && pip install --upgrade pip \
    && pip3 install --upgrade pip \
    && echo "Installing Oracle JDK 8 ..." \
    && add-apt-repository -y ppa:webupd${JAVA_VERSION}team/java \
    && apt-get update -q \
    && echo debconf shared/accepted-oracle-license-v$ORACLE_LICENSE_VERSION select true | debconf-set-selections \
    && echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections \
    && apt-get install -y oracle-java${JAVA_VERSION}-installer oracle-java${JAVA_VERSION}-set-default \
    && echo "Installing scala... " \
    && curl -LO http://www.scala-lang.org/files/archive/scala-$SCALA_VERSION.deb \
    && dpkg -i ./scala-$SCALA_VERSION.deb \
    && rm -f ./scala-$SCALA_VERSION.deb \
    && echo "Install Node.js ..." \
    && curl -sL https://deb.nodesource.com/setup_$NODEJS_VERSION | sudo -E bash - \
    && sudo apt-get install -y nodejs \
    && echo "Install R ..." \
    && apt-get install -y apt-transport-https \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 \
    && add-apt-repository 'deb [arch=amd64,i386] https://cran.rstudio.com/bin/linux/ubuntu yakkety/' \
    && apt-get update \
    && apt-get install -y r-base --no-install-recommends \
    && echo "Install docker ..." \
    && apt-get -y remove docker docker-engine docker.io \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
    && apt-key fingerprint 0EBFCD88 \
    && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    && apt-get update \
    && apt-get install -y docker-ce \
    && curl -L https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose \
    && chmod 777 /usr/local/bin/docker-compose \
    && echo "Install Go-lang" \
    && curl -L https://storage.googleapis.com/golang/go1.9.linux-amd64.tar.gz -o /root/go$GO_VERSION.$GO_OS-$GO_ARCH.tar.gz \
    && tar -C /usr/local -xzf /root/go$GO_VERSION.$GO_OS-$GO_ARCH.tar.gz \
    && rm -f /root/go$GO_VERSION.$GO_OS-$GO_ARCH.tar.gz \
    && ln -s /usr/local/go-* /usr/local/go \
    && echo "Cleaning cache ..." \
    && apt-get clean \
    && apt-get -y autoclean \
    && rm -rf /var/lib/apt/lists/* \
    && echo "Refinement of sshd config file ..." \
    && sed -i "s/\#AuthorizedKeysFile/AuthorizedKeysFile/g" /etc/ssh/sshd_config \
    && sed -i "s/\#UseLogin no/UseLogin yes/g" /etc/ssh/sshd_config \
    && sed -i "s/\#PasswordAuthentication/PasswordAuthentication/g" /etc/ssh/sshd_config

ADD docker-start-agent.sh /docker-start-agent.sh

ADD docker-entrypoint.sh /docker-entrypoint.sh

ADD bin/install-credentials.sh /usr/local/bin/install-credentials

ADD bin/custom-start-docker.sh /usr/local/bin/custom-start-docker

ADD bin/custom-stop-docker.sh /usr/local/bin/custom-stop-docker

ADD files/docker /etc/init.d/docker

RUN useradd -m -d $JENKINS_HOME -s /bin/bash -p jenkins jenkins \
    && echo "jenkins\njenkins"|sudo passwd jenkins \
    && echo "Init jenkins super-user ..." \
    && cp /etc/sudoers /root/sudoers \
    && chmod 777 /root/sudoers \
    && echo "jenkins  ALL=(ALL) NOPASSWD:ALL" >> /root/sudoers \
    && chmod 400 /root/sudoers \
    && mv /root/sudoers /etc/sudoers \
    && usermod -aG ssh jenkins \
    && usermod -aG docker jenkins \
    && rm -f /usr/bin/python \
    && ln -s /usr/bin/python3 /usr/bin/python \
    && chmod 777 /docker* \
    && chmod 777 /etc/init.d/docker \
    && chmod 777 /usr/local/bin/* \
    && mkdir -p $GOPATH \
    && chown jenkins:jenkins $GOPATH \
    && mkdir -p /etc/docker \
    && mkdir -p /var/lib/docker \
    && chown -Rf jenkins:jenkins /home \
    && mkdir -p /home/jenkins/.m2 \
    && chmod -Rf 666 /etc/docker
USER jenkins

WORKDIR $JENKINS_HOME

COPY files/jenkins-ssh.tgz $JENKINS_HOME/jenkins-ssh.tgz

EXPOSE 22

VOLUME ["/var/lib/docker", "/home/jenkins/.m2"]

CMD /docker-start-agent.sh -daemon

ENTRYPOINT /docker-entrypoint.sh
