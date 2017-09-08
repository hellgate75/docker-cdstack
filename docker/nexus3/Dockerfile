FROM sonatype/nexus3:3.5.0

MAINTAINER Fabrizio Torelli <hellgate75@gmail.com>

LABEL vendor="Fabrizio Torelli <hellgate75@gmail.com>"
LABEL com.docker.image.license="LGPL License, Version 3.0"
LABEL com.docker.image.name="Nexus 3 Repository Manager Pro base image"
LABEL com.docker.image.type="Nexus 3 Continuous Delivery Repository Image"

USER root

ENV PATH=${NEXUS_HOME}/bin:$PATH \
    NEXUS_CONTEXT="/" \
    NEXUS_PORT="8081" \
    NEXUS_HOST="0.0.0.0" \
    JVM_MAX_MEM="2G" \
    JVM_MAX_HEAP="2G" \
    JVM_MIN_HEAP="256m"

COPY docker-start-nexus.sh /docker-start-nexus.sh

COPY docker-entrypoint.sh /docker-entrypoint.sh

COPY nexus.properties $NEXUS_DATA/etc/nexus.properties

RUN yum -y install wget curl git maven gradle sudo net-tools vim patch make gcc \
    pexpect expect \
    && yum clean all \
    && echo "Init nexus super-user ..." && cp /etc/sudoers /root/sudoers \
    && chmod 777 /root/sudoers \
    && echo "nexus  ALL=(ALL) NOPASSWD:ALL" >> /root/sudoers \
    && chmod 400 /root/sudoers && mv /root/sudoers /etc/sudoers \
    && chmod 777 /docker-* \
    && chown -R nexus:nexus $NEXUS_HOME \
    && echo "-Xms$JVM_MIN_HEAP" >> $NEXUS_HOME/bin/nexus.vmoptions \
    && echo "-Xmx$JVM_MAX_HEAP" >> $NEXUS_HOME/bin/nexus.vmoptions

RUN echo -e "root\nroot" |  passwd

WORKDIR ${NEXUS_HOME}

VOLUME ${NEXUS_DATA}

EXPOSE 8081 2480

USER nexus

CMD /docker-start-nexus.sh -daemon

ENTRYPOINT /docker-entrypoint.sh
