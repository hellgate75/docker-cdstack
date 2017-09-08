FROM sonarqube:6.5

MAINTAINER Fabrizio Torelli <hellgate75@gmail.com>

LABEL vendor="Fabrizio Torelli <hellgate75@gmail.com>"
LABEL com.docker.image.license="LGPL License, Version 3.0"
LABEL com.docker.image.name="SonarQube Quality Gate base image"
LABEL com.docker.image.type="SonarQube Continuous Delivery Quality Gate Image"
# Customize drivers attaching a volume to /opt/sonarqube/lib/jdbc
ENV PATH=/usr/local/bin:/opt/sonarqube/bin:$PATH
ENV DEBIAN_FRONTEND=noninteractive
ENV SONARQUBE_HOME="/opt/sonarqube"
ENV SONARQUBE_JDBC_USERNAME="sonar"
ENV SONARQUBE_JDBC_PASSWORD="sonar"
ENV SONARQUBE_JDBC_URL="jdbc:postgresql://localhost/sonar"
ENV SONARQUBE_WEB_JVM_OPTS="-server -Xmx1G -Xms128m -XX:+HeapDumpOnOutOfMemoryError"
ENV SONARQUBE_ELASTICSEARCH_JVM_OPTS="-Xmx1G -Xms256m -Xss256k -Djna.nosys=true -XX:+UseParNewGC -XX:+UseConcMarkSweepGC -XX:CMSInitiatingOccupancyFraction=75 -XX:+UseCMSInitiatingOccupancyOnly -XX:+HeapDumpOnOutOfMemoryError"
ENV SONARQUBE_COMPUTEENGINE_JVM_OPTS="-server -Xmx512m -Xms128m -XX:+HeapDumpOnOutOfMemoryError"
ENV SONARQUBE_REINSTALL_PLUGIN="0"
ENV SONARQUBE_HOST="0.0.0.0"
ENV SONARQUBE_WEB_PORT=9000
ENV SONARQUBE_WEB_CONTEXT="/"
ENV STARTUP_TIMEOUT_SECONDS=5
ENV PLUGINS_FILE_URL=""

WORKDIR $SONARQUBE_HOME

USER root

RUN apt-get update \
    &&  apt-get -y install apt-utils \
    &&  apt-get -y install --no-install-recommends sudo openssl tar groovy unzip monit ca-certificates \
              openssh-server cron wget curl htop git maven gradle vim net-tools zip postgresql-client locales \
    &&  apt-get -y upgrade \
    &&  mkdir -p $SONARQUBE_HOME/bin \
    &&  apt-get -y autoremove \
    &&  apt-get -y clean \
    &&  rm -rf /var/lib/apt/lists/*

COPY bin/start-sonarqube.sh $SONARQUBE_HOME/bin/start-sonarqube

COPY bin/stop-sonarqube.sh $SONARQUBE_HOME/bin/stop-sonarqube

COPY bin/status-sonarqube.sh $SONARQUBE_HOME/bin/status-sonarqube

COPY bin/install-plugins.sh $SONARQUBE_HOME/bin/install-plugins-sonarqube

COPY bin/dump-env.sh /usr/local/bin/dump-env

COPY docker-entrypoint.sh /docker-entrypoint.sh

COPY docker-start-sonarqube.sh /docker-start-sonarqube.sh

COPY init.sonarqube.sh /etc/init.d/sonarqube

COPY default.sonarqube.sh /etc/default/sonarqube

COPY sonar.properties /opt/sonarqube/conf/sonar.properties

COPY remotedb/create_schema.sql ~/create_schema.sql

COPY samples/plugins.txt /root/.sonarqube/plugins.txt

RUN chmod 777 $SONARQUBE_HOME/bin/* \
    &&  chmod 777 /docker-*.sh \
    &&  chmod 777 /etc/init.d/sonarqube \
    &&  chmod 777 /etc/default/sonarqube \
    &&  chmod 777 /usr/local/bin/dump-env \
    && mkdir -p /root/.ssh \
    && usermod -aG ssh root \
    && cp /etc/ssh/sshd_config /etc/ssh/sshd_config.orig

VOLUME "/opt/sonarqube/data"

CMD /docker-start-sonarqube.sh  -daemon

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 9000 9001 9092
