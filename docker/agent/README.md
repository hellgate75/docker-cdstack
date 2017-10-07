# Jenkins® Docker image


Docker Image for Jenkins® Gent Node. This Docker image provides following languages build environments:
* Java 8
* Groovy
* Maven
* Gradle
* Scala
* R
* Python (pip is present)
* Ruby
* Nodejs
* docker (docker-compose is present)
* Go


### Introduction ###

Jenkins® agent offers to Jenkins images a performing and complete build and deployment environment.


### Docker Image information ###

Here some information :


Volumes : /var/lib/docker, /home/jenkins/.m2

* `/var/lib/docker` :

Docker® data storage folder.

* `/home/jenkins/.m2` :

Apache® Maven data storage folder.


Ports:

Jenkins® agent ports:

* 22 (ssh interface)


Environment variables:

* `SSH_KEY_FILES_TAR_GZ_URL`: Remote archive (tar-gzipped) file url containing SSH keys and configuration for jenkins user folder .ssh (default: )
* `GIT_USER_NAME`: GIT user name to be applied to pull projects (default: )
* `GIT_USER_EMAIL`: GIT user email id to be applied to pull projects (default: )


### Docker Image build ###

Image can be built manually, into image folder, using following docker command :

```bash
        docker build --no-cache --rm --force-rm --tag jenkins-agent .
```

Or you can simply build with docker-compose following file :

[docker-compose-jenkins.yml](/docker/samples/docker-compose-jenkins.yml)

From project root using this command :

```bash
        docker-compose -f samples/docker-compose-jenkins.yml build
```

And you will build and build Jenkins® echo-system containers sample environment.


### Docker Image execution ###

Image can be executed manually, into image folder, using following docker command :

```bash
        docker run -d -ti --name jenkins-agent -p 4422:22  jenkins-agent .
```

Or you can simply execute with docker-compose following file :

[docker-compose-jenkins.yml](/docker/samples/docker-compose-jenkins.yml)

From project root using this command :

```bash
        docker-compose -f samples/docker-compose-jenkins.yml up -d
```

And you will build and execute Jenkins® echo-system containers sample environment.


### Docker Image tips ###

For any tip in configuration for Jenkins® docker container you can refer to sample [docker-compose-local.yml](/docker/samples/docker-compose-local.yml).

In order to build all Continuous Integration infrastructure, in the project root, please execute following docker compose command :

```bash
        docker-compose -f samples/docker-compose-local.yml up -d
```
