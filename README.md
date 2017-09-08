# README #

This README would normally document whatever steps are necessary to get your application up and running.

### What is this repository for? ###

* Version 1.0.0
* [Learn Markdown](https://bitbucket.org/tutorials/markdowndemo)


### Prerequisites ###

In order to execute compose you need :
* docker v.  


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

### License ###

[LGPL v.3](https://github.com/hellgate75/doker-cdstack/tree/master/LICENSE)
