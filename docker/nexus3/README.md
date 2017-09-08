# Sonatype™ Nexus® OSS Docker image


Docker Image for Nexus® OSS Node. This Docker image provides environment, JVM and remote database configuration.


### Introduction ###

Nexus® OSS software (previously called Sonar) is an open source artifact repository platform, dedicated to store artifacts from different technologies.


Store

Give your teams a single source of truth for every component they use.


Cache

Optimize build performance and reliability by caching proxies of remote repositories.


Adapt

Provide universal coverage for all major package formats and types.


Scale

Install on an unlimited amount of servers for an unlimited amount of users.


### Docker Image information ###

Here some information :

s
Volumes : /nexus-data

* `/nexus-data` :

Nexus® OSS data storage folder.


Ports:

Nexus® OSS ports:

* 8081 (web interface)

* 2480 (OrientDb studio web interface)


Environment variables:

* `NEXUS_CONTEXT` : Web Context for Application (default: `/`)
* `NEXUS_PORT` : Web Access Port (default: `8081`)
* `NEXUS_HOST` : Docker container Web App host (default: `0.0.0.0`)
* `JVM_MAX_MEM` : Maximum used memory (default: `2G`)
* `JVM_MAX_HEAP` : Maximum JVM Heap Memory (default: `2G`)
* `JVM_MIN_HEAP` : Minimum JVM Heap Memory (default: `256m`)


### Docker Image build ###

Image can be built manually, into image folder, using following docker command :

```bash
        docker build --no-cache --rm --force-rm --tag nexus3 .
```

Or you can simply build with docker-compose following file :

[docker-compose-nexus.yml](/docker/samples/docker-compose-nexus.yml)

From project root using this command :

```bash
        docker-compose -f samples/docker-compose-nexus.yml build
```

And you will build and build Nexus® OSS standalone sample environment.


### Docker Image execution ###

Image can be executed manually, into image folder, using following docker command :

```bash
        docker exec -d --name nexus3 -p 8081:8081 -e "NEXUS_CONTEXT=/" nexus3 .
```

Or you can simply execute with docker-compose following file :

[docker-compose-nexus.yml](/docker/samples/docker-compose-nexus.yml)

From project root using this command :

```bash
        docker-compose -f samples/docker-compose-nexus.yml up -d
```

And you will build and execute Nexus® OSS standalone sample environment.


### Docker Image tips ###

For any tip in configuration for Nexus® OSS docker container you can refer to sample [docker-compose-local.yml](/docker/samples/docker-compose-local.yml).

In order to build all Continuous Integration infrastructure, in the project root, please execute following docker compose command :

```bash
        docker-compose -f samples/docker-compose-local.yml up -d
```
