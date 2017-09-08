# Sonar™ SonarQube® Docker image


Docker Image for SonarQube® Node. This Docker image provides environment, JVM and remote database configuration.


### Introduction ###

SonarQube® software (previously called Sonar) is an open source quality management platform, dedicated to continuously analyze and measure technical quality, from project portfolio to method. If you wish to extend the SonarQube platform with open source plugins, have a look at our plugin library.


### Docker Image information ###

Here some information :

s
Volumes : /opt/sonarqube/data

* `/opt/sonarqube/data` :

SonarQube® data storage folder.


Ports:

SonarQube® ports:

* 9000 (web interface)

* 9001 (elastic search port)

* 9092 ()


Environment variables:

* `SONARQUBE_JDBC_USERNAME` : SonarQube® backing database Jdbc connection user  (default: `sonar`)

* `SONARQUBE_JDBC_PASSWORD` : SonarQube® backing database Jdbc connection password  (default: `sonar`)

* `SONARQUBE_JDBC_URL` : SonarQube® backing database Jdbc connection url  (default: `jdbc:postgresql://localhost/sonar`)

* `SONARQUBE_WEB_JVM_OPTS` : SonarQube® Web Service JVM options  (default: `-server -Xmx1G -Xms128m -XX:+HeapDumpOnOutOfMemoryError`)

* `SONARQUBE_ELASTICSEARCH_JVM_OPTS` : SonarQube® ElsticSearch Service JVM options  (default: `-Xmx1G -Xms256m -Xss256k -Djna.nosys=true -XX:+UseParNewGC -XX:+UseConcMarkSweepGC -XX:CMSInitiatingOccupancyFraction=75 -XX:+UseCMSInitiatingOccupancyOnly -XX:+HeapDumpOnOutOfMemoryErrorr`)

* `SONARQUBE_COMPUTEENGINE_JVM_OPTS` : SonarQube® ComputeEngine Service JVM options  (default: `-server -Xmx512m -Xms128m -XX:+HeapDumpOnOutOfMemoryError`)

* `SONARQUBE_WEB_CONTEXT` : SonarQube® Web Service http context  (default: `/`)
* `SONARQUBE_REINSTALL_PLUGIN`: Reset and reinstall plugins, when value is not zero make a reinstall of all SonarQube® plugins. Mandatory when import first time a previous volume. (default: 0)

* `STARTUP_TIMEOUT_SECONDS` : SonarQube® startup delay in seconds, for database connectivity lag (default: `5`)

* `PLUGINS_FILE_URL` : SonarQube® plugin list file remote URL (default: )


### Docker Image build ###

Image can be built manually, into image folder, using following docker command :

```bash
        docker build --no-cache --rm --force-rm --tag sonarqube .
```

Or you can simply build with docker-compose following file :

[docker-compose-sonarqube.yml](/docker/samples/docker-compose-sonarqube.yml)

From project root using this command :

```bash
        docker-compose -f samples/docker-compose-sonarqube.yml build
```

And you will build and build SonarQube® standalone sample environment.


### Docker Image execution ###

Image can be executed manually, into image folder, using following docker command :

```bash
        docker exec -d --name sonarqube -p 9000:9000 -e "SONARQUBE_WEB_CONTEXT=/sonar" \
        -e "SONARQUBE_JDBC_URL=<your database connection string>" -e "SONARQUBE_JDBC_USERNAME=<your database user name>" \
         -e "SONARQUBE_JDBC_PASSWORD=<your database user password>" sonarqube .
```

Or you can simply execute with docker-compose following file :

[docker-compose-sonarqube.yml](/docker/samples/docker-compose-sonarqube.yml)

From project root using this command :

```bash
        docker-compose -f samples/docker-compose-sonarqube.yml up -d
```

And you will build and execute SonarQube® standalone sample environment.


### How do you can integrate SonarQube in code? ###

Here some samples:

* Maven:

```bash
mvn sonar:sonar \
  -Dsonar.host.url=http://sonar.cdnet:9000/sonar \
  -Dsonar.login=7226ae2686c1270803ad87782d890609c33b6ce4
```

* Gradle:
```bash
plugins {
  id "org.sonarqube" version "2.5"
}

./gradlew sonarqube \
  -Dsonar.host.url=http://sonar.cdnet:9000/sonar \
  -Dsonar.login=7226ae2686c1270803ad87782d890609c33b6ce4
  ```

* Node.Js:
```bash
sonar-scanner \
  -Dsonar.projectKey=vanilla-ssp-plus-front-end \
  -Dsonar.sources=. \
  -Dsonar.host.url=http://sonar.cdnet:9000/sonar \
  -Dsonar.login=7226ae2686c1270803ad87782d890609c33b6ce4
  ```


### Docker Image tips ###

If you consider to define a new SonarQube® database, please consider that in case you want to use PostgreSQL, you have to prepare a schema for
new database accordingly to [database sql sample](/docker/sonarqube/remotedb/create_schema.sql).

Anyway you can refer to sample [docker-compose-local.yml](/docker/samples/docker-compose-local.yml) in order to mind how you can configure database docker container and SonarQube® docker container.

In order to build all Continuous Integration infrastructure, in the project root, please execute following docker compose command :

```bash
        docker-compose -f samples/docker-compose-local.yml up -d
```
