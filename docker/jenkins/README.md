# Jenkins® Docker image


Docker Image for Jenkins® Node. This Docker image provides environment, JVM, plugins and seed job configuration.


### Introduction ###

Jenkins® software is an open source Continuous Integration platform, dedicated to run pipelines for code from different technologies.


### Build great things at any scale ###

The leading open source automation server, Jenkins provides hundreds of plugins to support building, deploying and automating any project.


### Docker Image information ###

Here some information :


Volumes : /var/jenkins_home

* `/var/jenkins_home` :

Jenkins® data storage folder.


Ports:

Jenkins® ports:

* 8080 (web interface)

* 50000 (Client REST interface)


Environment variables:

* `JENKINS_ADMIN_PASSWORD` : Jenkins® admin password (default: `jenkins`)
* `NUMBER_OF_JENKINS_EXECUTORS` : Number of executor threads (default: `5` )
* `PLUGINS_FILE_URL` : Remote text file url containing plugin names (default: )
* `PLUGINS_CONFIG_FILES_TAR_GZ_URL` : Remote archive (tar-gzipped) file url containing plugin configuration files (default: )
* `AGENT_ENVIRONMENT_BASH_SCRIPT_URL` : Remote bash script file url containing variable useful to configure Agent nodes (default: ) - work in progress
* `SSH_KEY_FILES_TAR_GZ_URL`: Remote archive (tar-gzipped) file url containing SSH keys and configuration for jenkins user folder .ssh (default: )
* `PROJECT_LIST_FILE_URL`: Remote text file url containing list of url of plugins to install (default: )
* `JENKINS_NODE_LIST_URL` : Remote text file url containing list of nodes in format [name|host|num_executors|ssh_user|ssh_password|opz_port] (default: ), we suggest in compose to use jenkins/jenkins as user name and password, and linux-agent-1/linux-agent-2 as node hosts, names
* `GIT_USER_NAME`: GIT user name to be applied to pull projects (default: )
* `GIT_USER_EMAIL`: GIT user email id to be applied to pull projects (default: )
* `SONARQUBE_URL`: Url of SonarQube® Server, for job environment purpose (default: )
* `SONARQUBE_APIKEY`: SonarQube® API Key, for job environment purpose (default: )
* `SONARQUBE_USER`: SonarQube® Scanner authorised user name, for job environment purpose (default: )
* `SONARQUBE_PASSWORD`: SonarQube® Scanner authorised user password, for job environment purpose (default: )
* `NEXUS_BASE_REPO_URL`: Nexus® 3 OSS Base URL, for job environment purpose (default: )
* `NEXUS_SNAPSHOT_REPO_URL`: Nexus® 3 OSS Snapshots Repository URL, for job environment purpose (default: )
* `NEXUS_RELEASE_REPO_URL`: Nexus® 3 OSS Releases Repository URL, for job environment purpose (default: )
* `NEXUS_STAGING_DOCKER_REPO_URL`: Nexus® 3 OSS Docker® Project Repository URL, for job environment purpose(default: )
* `NEXUS_PRODUCTION_DOCKER_REPO_URL`: Nexus® 3 OSS Docker® Production Repository URL, for job environment purpose(default: )
* `NEXUS_USER`: Nexus® 3 OSS authorised user name, for job environment purpose (default: )
* `NEXUS_PASSWORD`: Nexus® 3 OSS authorised user password, for job environment purpose (default: )
* `JVM_MAX_HEAP` : Maximum JVM Heap Memory (default: `2G`)
* `JVM_MIN_HEAP` : Minimum JVM Heap Memory (default: `256m`)


### Docker Image build ###

Image can be built manually, into image folder, using following docker command :

```bash
        docker build --no-cache --rm --force-rm --tag jenkins2 .
```

Or you can simply build with docker-compose following file :

[docker-compose-jenkins.yml](/docker/samples/docker-compose-jenkins.yml)

From project root using this command :

```bash
        docker-compose -f samples/docker-compose-jenkins.yml build
```

And you will build and build Jenkins® standalone container sample environment.


### Docker Image execution ###

Image can be executed manually, into image folder, using following docker command :

```bash
        docker exec -d --name jenkins2 -p 8080:8080 -p 50000:50000 -e "JENKINS_ADMIN_PASSWORD=mypassword" jenkins2 .
```

Or you can simply execute with docker-compose following file :

[docker-compose-jenkins.yml](/docker/samples/docker-compose-jenkins.yml)

From project root using this command :

```bash
        docker-compose -f samples/docker-compose-jenkins.yml up -d
```

And you will build and execute Jenkins® standalone container sample environment.


### Docker Image tips ###

For any tip in configuration for Jenkins® docker container you can refer to sample [docker-compose-local.yml](/docker/samples/docker-compose-local.yml).

In order to build all Continuous Integration infrastructure, in the project root, please execute following docker compose command :

```bash
        docker-compose -f samples/docker-compose-local.yml up -d
```
