<p align="center" style="width:100%;"><img  width="165" height="147" src="https://github.com/hellgate75/doker-cdstack/raw/master/images/docker.png" />&nbsp;&nbsp;&nbsp;&nbsp;<img  width="150" height="147" src="https://github.com/hellgate75/doker-cdstack/raw/master/images/docker-swarm.png" /></p>


# Docker CI-CD Sample #

This repository define a simple Docker Pipeline comosed by :
* Jenkins 2
* Nexus 3
* Sonarqube
* MySQL
* Ubuntu Jenkins agent nodes

This project has been defined to realize a simple resilient Pipeline, with auto-provisioned containers. It coud be a good example for defining an On-Premise or Cloud guested Swarm Nodes Production Environment.


<p align="center" style="width:100%;"><img  width="107" height="147" src="https://github.com/hellgate75/doker-cdstack/raw/master/images/jenkins.png" />&nbsp;&nbsp;&nbsp;&nbsp;<img  width="490" height="147" src="https://github.com/hellgate75/doker-cdstack/raw/master/images/nexus.png" />&nbsp;&nbsp;&nbsp;&nbsp;<img  width="225" height="147" src="https://github.com/hellgate75/doker-cdstack/raw/master/images/sonarqube.jpg" /></p>

<p align="center" style="width:100%;"><img  width="150" height="147" src="https://github.com/hellgate75/doker-cdstack/raw/master/images/docker-registry.png" />&nbsp;&nbsp;&nbsp;&nbsp;<img  width="147" height="147" src="https://github.com/hellgate75/doker-cdstack/raw/master/images/portainer-io.png" />&nbsp;&nbsp;&nbsp;&nbsp;<img  width="352" height="147" src="https://github.com/hellgate75/doker-cdstack/raw/master/images/mysql.jpg" /></p>

### What is this repository for? ###

Definition of Docker Compose and Docker Machine Swarm Nodes Ci/Cd Pipeline sample.

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

* [Jenkins Agent Node](https://github.com/hellgate75/doker-cdstack/tree/master/docker/agent)

* [Nexus 3 OSS](https://github.com/hellgate75/doker-cdstack/tree/master/docker/nexus3)

* [SonarQube](https://github.com/hellgate75/doker-cdstack/tree/master/docker/sonarqube)


### Local or Remote Swarm Option ###

We provide and automated Swarm Cluster procedure, that creates swarm nodes via docker machine virtualbox driver.

For Local Swarm cluster here a design picture.

<p align="center" style="width:100%;"><img  width="841" height="430" src="https://github.com/hellgate75/doker-cdstack/raw/master/images/design1.png" /></p>

Access to Swarm node management features is behalf bash shell script [/swarm/manage-swarm-env.sh](https://github.com/hellgate75/doker-cdstack/tree/master/swarm/manage-swarm-env.sh)

In folder [/swarm](https://github.com/hellgate75/doker-cdstack/tree/master/swarm/) you can access to [manage-swarm-env.sh](https://github.com/hellgate75/doker-cdstack/tree/master/swarm/manage-swarm-env.sh) script file.


Command Syntax is :

```bash
./manage-swarm-env.sh environment --create|--destroy|--start|--stop|--redeploy [environment] [suffix]
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

In case you consider to test this cluster with a not performing machine you can use cluster performances limitation bash script ( [/swarm/minimize-cluster.sh](https://github.com/hellgate75/doker-cdstack/tree/master/swarm/minimize-cluster.sh) ), usually executed in same shell before you create or manage Swarm Cluster. Example code to degrade Cluster performance on minimum viable ones (to be executed into [/swarm](https://github.com/hellgate75/doker-cdstack/tree/master/swarm) folder) is :
```bash
 source ./minimize-cluster.sh && \
 ./manage-swarm-env.sh ........................
```

If you use cluster performances limitation script to create the cluster, you have to execute that script, whenever you have to execute any other command on same cluster.


Unique available environment at the moment is : `local`


### Real Continuous Delivery Swarm environment ###

In a real continuous deivery environment, DevOps people should use network drivers to connect clusters. Most effective one is WaveNet. This plugin gives you all together : inter-cluster connectivity, TLS connection intransit encryption and internal mini-dns service. It is more secure than any DMZ network, and it lives only in docker namespace where this network is created.

[WaveNet Web Site](https://www.weave.works/docs/net/latest/overview) and here [docker installation instructions](https://www.weave.works/docs/net/latest/install/plugin/plugin-v2/#installation)

Here a sample effective design, just with one deployment connection (eg. It covers some app groups in staging environment).

<p align="center" style="width:100%;"><img  width="1024" height="672" src="https://github.com/hellgate75/doker-cdstack/raw/master/images/design2.png" /></p>



### License ###

Copyright (c) 2016-2017 [Fabrizio Torelli](https://www.linkedin.com/in/fabriziotorelli/)

Licensed under the [LGPL](https://github.com/hellgate75/doker-cdstack/tree/master/LICENSE) License (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

[LGPL v.3](https://github.com/hellgate75/doker-cdstack/tree/master/LICENSE)

You may also obtain distribution or production use written authorization, contactacting creator at

[Personal Email Address](mailto:hellgate75@gmail.com)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied,
further limitations in the license body.
See the License for the specific language governing permissions and
limitations under the License.
