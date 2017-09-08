#!/bin/bash

set -e

source /root/.sonarqube/.env

cd $SONARQUBE_HOME

if [ "${1:0:1}" != '-' ]; then
  exec "$@"
fi

exec java -jar $SONARQUBE_HOME/lib/sonar-application-$SONAR_VERSION.jar \
  -Dsonar.log.console=true \
  -Dsonar.jdbc.username="$SONARQUBE_JDBC_USERNAME" \
  -Dsonar.jdbc.password="$SONARQUBE_JDBC_PASSWORD" \
  -Dsonar.jdbc.url="$SONARQUBE_JDBC_URL" \
  -Dsonar.web.host="$SONARQUBE_HOST" \
  -Dsonar.web.port="$SONARQUBE_WEB_PORT" \
  -Dsonar.web.context="$SONARQUBE_WEB_CONTEXT" \
  -Dsonar.web.javaOpts="$SONARQUBE_WEB_JVM_OPTS -Djava.security.egd=file:/dev/./urandom" \
  -Dsonar.ce.javaOpts="$SONARQUBE_COMPUTEENGINE_JVM_OPTS -Djava.security.egd=file:/dev/./urandom" \
  -Dsonar.search.javaOpts="$SONARQUBE_ELASTICSEARCH_JVM_OPTS -Djava.security.egd=file:/dev/./urandom" \
  "$@"
