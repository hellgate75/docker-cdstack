# README #

This README would normally document whatever steps are necessary to get your application up and running.

### What is this repository for? ###

* Version 1.0.0
* [Learn Markdown](https://bitbucket.org/tutorials/markdowndemo)


### Pre-requisites ###

In order to execute compose you must ensure installation of :
* docker v. 17.0+
* docker-compose v. 1.13.0+

In order to execute swarm cluster you ensure installation of :
* docker v. 17.0+
* docker-compose v. 1.13.0+
* docker-machine v. 0.12.0+
* VirtualBox v. 5.1+

Scripting for automate execution of stack and Swarm environment are Lixux, Unix and Mac-OS compliant. Maybe you need install some further packages for monitoring and supporting pipeline execution (that can be required more for AWS and Azure future implementations).


### How to backup your volumes and restore it? ###

When you have some configuration on database or application containers and you want flash it to allow a recovery in a further time, there is a lot of work to do. We have defined a procedure to backup volumes and restore them, in a further time.

We suggest to stop containers before backup in order to prevent backup of partial or incompleted data.  

To backup volumes we provide following command :

```bash
backup-volume.sh <volume_name>
```

 This command will store volume data in an archive in folder archives, at same folder level of script.


 To restore volumes we provide following command :

 ```bash
 restore-volume.sh <volume_name>
 ```

  This command will create or update a volume with data stored in an archive in folder archives, at same folder level of script.

  We reccomand to define archives folder before starting with backup or restore activities.


  For vanilla project we provide an S3 backup for following volumes :

  * SonarQube Database (MySql) Docker Container Volume Backup File URL :

  https://s3-eu-west-1.amazonaws.com/ftorelli-docker-configuration/continuous-delivery/volumes/samples_sonarqube_db_data.tgz

  * SonarQube Docker Container Volume Backup File URL :

  https://s3-eu-west-1.amazonaws.com/ftorelli-docker-configuration/continuous-delivery/volumes/samples_sonarqube_data.tgz

  * Nexus3 OSS Docker Container Volume Backup File URL :

  https://s3-eu-west-1.amazonaws.com/ftorelli-docker-configuration/continuous-delivery/volumes/samples_nexus3_data.tgz

  Procedure to restore that volumes in project root :
  1. Create in same backup-volume.sh restore-volume.sh a folder named archives.
  2. Rename archive names with target docker volumes ones.
  3. Run restore-volume passing as parameter name of new target docker volume name (existing or not existing one).
  4. Run docker-compose or swarm stack and automatically volumes will be attached to docker containers.


### Available Docker Images ###

For further information please read related docker images documentation at :

* [Jenkins 2](https://github.com/hellgate75/doker-cdstack/tree/master/docker/jenkins)

* [Nexus 3 OSS](https://github.com/hellgate75/doker-cdstack/tree/master/docker/nexus3)

* [SonarQube](https://github.com/hellgate75/doker-cdstack/tree/master/docker/sonarqube)


### Local or Remote Swarm Option ###

We provide and automated Swarm Cluster procedure, that creates swarm nodes via docker machine virtualbox driver.

Access to Swarm node management features is behalf bash shell script [/swarm/manage-swarm-env.sh](https://github.com/hellgate75/doker-cdstack/tree/master/swarm/manage-swarm-env.sh)

In folder [/swarm](https://github.com/hellgate75/doker-cdstack/tree/master/swarm/) you can access to [manage-swarm-env.sh](https://github.com/hellgate75/doker-cdstack/tree/master/swarm/manage-swarm-env.sh) script file.


Command Syntax is :

```bash
manage-swarm-env.sh environment --create|--destroy|--start|--stop|--redeploy [environment] [suffix]
[environment]      Type of environment to use [local, aws or azure]
--create     Crete or update platform in case of stop of nodes
       [--force-rebuild]  Force rebuild local docker images
       [suffix]           If used qualify name of local or remote machines
--destroy    Destroy Platform
       [suffix]           If used qualify name of local or remote machines
--start      Start Platform Virtual Machines
       [suffix]           If used qualify name of local or remote machines
--stop         Stop Platform Virtual Machines
       [suffix]           If used qualify name of local or remote machines
--redeploy    Re-deploy Continuous Delivery stack preserving volumes
       [--rebuild]        Rebuild and push docker imges from source
       [--copyyaml]       Copy Swarm Script folder and fix registry path
       [--force-rebuild]  Force rebuild local docker images
       [suffix]           If used qualify name of local or remote machines
```

Unique available environment at the moment is : `local`


### License ###

[LGPL v.3](https://github.com/hellgate75/doker-cdstack/tree/master/LICENSE)
