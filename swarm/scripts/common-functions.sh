#!/bin/bash

DOCKER_FOLDER_PATH="$(cd $(pwd)/../docker && pwd)"

##########################################################################
## Define project name and prject prefix                                ##
##########################################################################
PROJECT_NAME="${SWARM_PROJECT_NAME:-"Delivery Sample"}"
PROJECT_PREFIX="${SWARM_PROJECT_PREFIX:-"sample"}"
PROJECT_REGISTRY_USERNAME="${SWARM_REGISTRY_USER:-"admin"}"
PROJECT_REGISTRY_PASSWORD="${SWARM_REGISTRY_PASSWORD:-"admin"}"

##########################################################################
## Print commmand usage                                                 ##
## Parameters :                                                         ##
##   (none)                                                             ##
## Returns:                                                             ##
##   - command usage text                                               ##
##########################################################################
function logo() {
  echo "##########################################################################"
  echo " $PROJECT_NAME Project - Continuous Delivery Platform"
  echo "##########################################################################"
  echo " "
  echo " "
  echo "      D O C K E R"
  echo ""
  echo "       #####    ###   ###     ###     #######    ###   ###"
  echo "      # ### #   # #   # #   # # # #   #  ### #   #  # #  #"
  echo "      # # ###   # #   # #  # #   # #  # #   # #  #   #   #"
  echo "       # #      # #   # #  # #   # #  # #### #   # ## ## #"
  echo "        # #     # # # # #  # ##### #  # ### #    # # # # #"
  echo "          # #   # ## ## #  # ##### #  # #  # #   # #   # #"
  echo "      ###  # #  #   #   #  # #   # #  # #   # #  # #   # #"
  echo "      # ###  #  # ## ## #  # #   # #  # #   # #  # #   # #"
  echo "       ######   ###   ###  ###   ###  ###   ###  ###   ###"
  echo " "
  echo "      T O O L S E T"
  echo " "
  echo " "
  echo "##########################################################################"
  echo "## S W A R M   N O D E S   M A N A G E M E N T   S W I S S - K N I F E  ##"
  echo "##########################################################################"
  echo " "
  echo "##########################################################################"
  echo " Project Prefix: $PROJECT_PREFIX"
  echo "##########################################################################"
  echo " "
  echo " "
  echo " "
}

##########################################################################
## Print commmand usage                                                 ##
## Parameters :                                                         ##
##   (none)                                                             ##
## Returns:                                                             ##
##   - command usage text                                               ##
##########################################################################
function usage() {
  echo "Usage : "
  echo "        manage-swarm-env.sh environment --create|--destroy|--start|--stop|--redeploy [environment] [suffix]"
  echo "        [environment]      Type of environment to use [local, aws or azure]"
  echo "        --create     Crete or update platform in case of stop of nodes"
  echo "               [--force-rebuild]  Force rebuild local docker images"
  echo "               [suffix]           If used qualify name of local or remote machines"
  echo "        --destroy    Destroy Platform"
  echo "               [suffix]           If used qualify name of local or remote machines"
  echo "        --start      Start Platform Virtual Machines"
  echo "               [suffix]           If used qualify name of local or remote machines"
  echo "        --stop         Stop Platform Virtual Machines"
  echo "               [suffix]           If used qualify name of local or remote machines"
  echo "        --redeploy    Re-deploy Continuous Delivery stack preserving volumes"
  echo "               [--rebuild]        Rebuild and push docker imges from source"
  echo "               [--copyyaml]       Copy Swarm Script folder and fix registry path"
  echo "               [--force-rebuild]  Force rebuild local docker images"
  echo "               [suffix]           If used qualify name of local or remote machines"
}

##########################################################################
## Define well-formed docker-machine name suffix                        ##
## Parameters :                                                         ##
##   - Suffix (string) [nullable]                                       ##
## Returns:                                                             ##
##   - Suffix complete or empty string                                  ##
##########################################################################
function checkSuffix() {
  if ! [[ -z "$(echo $1|grep "\-\-")" ]]; then
    echo ""
  else
    SUFFIX="$1"
    if [[ -z "$SUFFIX" ]]; then
      echo ""
    else
      echo "-$SUFFIX"
    fi
  fi
}

##########################################################################
## Print advertise for stack usage                                      ##
## Parameters :                                                         ##
##   - Suffix (string) [NOT nullable]                                   ##
##   - Leader Ip (string) [NOT nullable]                                ##
## Returns:                                                             ##
##   - Advertise text                                                   ##
##########################################################################
function advertise() {
  echo "You can access Portainer console at : http://$2:9091/"
  echo "Login to console with user 'admin' and password 'admin123', then manage your Swarm Cluster!!"
  echo ""
  echo "Jenkis console at : http://$2:8080/"
  echo "Nexus 3 OSS console at : http://$2:8085/"
  echo "SonarQube console at : http://$2:9000/sonar"
  echo ""
  echo "Before run your experience, please, verify yourself from logs that Jenkins, Sonaqube and Nexus are completely running ..."
  echo "docker-machine ssh $PROJECT_PREFIX-jenkins$1    and then docker ps and docker logs -f <jenkins-container-id>"
  echo "docker-machine ssh $PROJECT_PREFIX-nexus$1    and then docker ps and docker logs -f <nexus-container-id>"
  echo "docker-machine ssh $PROJECT_PREFIX-sonarqube$1    and then docker ps and docker logs -f <sonarqube-container-id>"
}


##########################################################################
## Private function                                                     ##
##########################################################################
## Execute Certificate installation                                     ##
## Parameters :                                                         ##
##   - Environment (string) [NOT nullable]                              ##
##   - Docker Machine full name (string) [NOT nullable]                 ##
##   - LEADER IP (string) [NOT nullable]                                ##
## Returns:                                                             ##
##   (none)                                                             ##
##########################################################################
function runRemoteCertificatesInstall() {
  docker-machine ssh $1 "sudo mkdir -p '/etc/docker/cert.d/$2:5000'"
  docker-machine ssh $1 "sudo cp /home/docker/domain.crt '/etc/docker/cert.d/$2:5000/ca.crt'"
  docker-machine ssh $1 "sudo mv /home/docker/domain.crt /etc/ssl/certs/domain.crt"
  docker-machine ssh $1 "sudo mv /home/docker/domain.key /etc/ssl/private/domain.key"
  ## Chnge on my local docker boot2iso command!!
  # REGISTRY_LOGIN="echo \"$PROJECT_REGISTRY_PASSWORD\" | docker login --username $PROJECT_REGISTRY_USERNAME --password-stdin  http://$3:5000"
  REGISTRY_LOGIN="docker login --username $PROJECT_REGISTRY_USERNAME --password $PROJECT_REGISTRY_PASSWORD http://$2:5000"
  docker-machine ssh $1 "echo \"$REGISTRY_LOGIN\" >> /home/docker/.profile"
  docker-machine ssh $1 "sudo /etc/init.d/docker restart"
}


##########################################################################
## Install docker secure registry TLS certificates                      ##
## Parameters :                                                         ##
##   - local path (string) [NOT nullable]                              ##
##   - Docker Machine full name (string) [NOT nullable]                 ##
##   - LEADER IP (string) [NOT nullable]                                ##
## Returns:                                                             ##
##   (none)                                                             ##
##########################################################################
function installCertificates() {
  echo "Copying certificate from source folder $1 to $2 docker machine ..."
  docker-machine scp -r $1/domain.crt $2:/home/docker/domain.crt
  docker-machine scp -r $1/domain.key $2:/home/docker/domain.key
  runRemoteCertificatesInstall ${@:2}
}

##########################################################################
## Install local docker secure registry TLS certificates                ##
## Parameters :                                                         ##
##   - remote path (string) [NOT nullable]                              ##
##   - Docker Machine full name (string) [NOT nullable]                 ##
##   - LEADER IP (string) [NOT nullable]                                ##
## Returns:                                                             ##
##   (none)                                                             ##
##########################################################################
function installLocalCertificates() {
  echo "Copying certificate from source folder $1 to $2 docker machine ..."
  docker-machine ssh $2 "cp -Rf $1/domain.crt /home/docker/domain.crt"
  docker-machine ssh $2 "cp -Rf $1/domain.key /home/docker/domain.key"
  runRemoteCertificatesInstall ${@:2}
}


##########################################################################
## Copy source folders to docker-machine                                ##
## Parameters :                                                         ##
##   - Docker Machine full name (string) [NOT nullable]                 ##
##   - base folder path (string) [NOT nullable]                         ##
## Returns:                                                             ##
##   (none)                                                             ##
##########################################################################
function copySourceFolders() {
  echo "Copying docker images source folders from $2 to $1 docker machine ..."
  docker-machine scp -r $2/jenkins   $1:/home/docker/jenkins
  docker-machine scp -r $2/nexus3    $1:/home/docker/nexus3
  docker-machine scp -r $2/sonarqube $1:/home/docker/sonarqube
}

##########################################################################
## Copy local source folders to docker-machine                          ##
## Parameters :                                                         ##
##   - Docker Machine full name (string) [NOT nullable]                 ##
##   - remote folder path (string) [NOT nullable]                       ##
## Returns:                                                             ##
##   (none)                                                             ##
##########################################################################
function copyLocalSourceFolders() {
  echo "Copying docker images source folders from $2 to $1 docker machine ..."
  docker-machine ssh $1 "cp -Rf $2/jenkins   /home/docker/jenkins"
  docker-machine ssh $1 "cp -Rf $2/nexus3    /home/docker/nexus3"
  docker-machine ssh $1 "cp -Rf $2/sonarqube /home/docker/sonarqube"
}

##########################################################################
## Migrate docker volumes on solid drive                                ##
## Parameters :                                                         ##
##   - Docker Machine full name (string) [NOT nullable]                 ##
## Returns:                                                             ##
##   (none)                                                             ##
##########################################################################
function createDockerInSolidVolume() {
  echo "Mounting docker folder and docker user home on solid drive ..."
  docker-machine ssh $1 "sudo sh -c \"mkdir -p /mnt/sda1/var/lib/solid && mv /var/lib/docker /mnt/sda1/var/lib/solid/ && ln -s /mnt/sda1/var/lib/solid/docker /var/lib/docker\""
  docker-machine ssh $1 "sudo sh -c \"mkdir -p /mnt/sda1/var/lib/solid/run && mv /var/run/docker /mnt/sda1/var/lib/solid/run/ && ln -s /mnt/sda1/var/lib/solid/run/docker /var/run/docker\""
}

##########################################################################
## Remount docker volumes from solid drive                              ##
## Parameters :                                                         ##
##   - Docker Machine full name (string) [NOT nullable]                 ##
## Returns:                                                             ##
##   (none)                                                             ##
##########################################################################
function remountDockerInSolidVolume() {
  echo "Mounting docker folder and docker user home on solid drive ..."
  docker-machine ssh $1 "sudo sh -c \"rm -Rf /var/lib/docker && ln -s /mnt/sda1/var/lib/solid/docker /var/lib/docker\""
}

##########################################################################
## Create/Mount Docker extra files folder on solid drive                ##
## Parameters :                                                         ##
##   - Docker Machine full name (string) [NOT nullable]                 ##
## Returns:                                                             ##
##   (none)                                                             ##
##########################################################################
function mountDockerLibHomeSolidVolume() {
  docker-machine ssh $1 "mkdir -p /var/lib/home/docker && sudo sh -c \"mkdir -p /mnt/sda1/var/lib/swarm  && ln -s /mnt/sda1/var/lib/swarm /var/lib/home/docker/swarm && chown docker:docker -Rf /mnt/sda1/var/lib/swarm && chown docker:docker -Rf /var/lib/home\""
}

##########################################################################
## Remount Docker extra files folder from solid drive                   ##
## Parameters :                                                         ##
##   - Docker Machine full name (string) [NOT nullable]                 ##
## Returns:                                                             ##
##   (none)                                                             ##
##########################################################################
function remountDockerLibHomeSolidVolume() {
  docker-machine ssh $1 "mkdir -p /var/lib/home/docker && sudo sh -c \"ln -s /mnt/sda1/var/lib/swarm /var/lib/home/docker/swarm && chown docker:docker -Rf /mnt/sda1/var/lib/swarm && chown docker:docker -Rf /var/lib/home\""
}

##########################################################################
## Build Docker images                                                  ##
## Parameters :                                                         ##
##   - Docker Machine full name (string) [NOT nullable]                 ##
##   - LEADER IP (string) [NOT nullable]                                ##
## Returns:                                                             ##
##   (none)                                                             ##
##########################################################################
function buildCDDockerImages() {
  echo "Provisioning $PROJECT_PREFIX-jenkins docker image"
  docker-machine ssh $1 "cd ./jenkins && docker build --rm --force-rm --no-cache --tag hellgate75/$PROJECT_PREFIX-jenkins . && docker tag hellgate75/$PROJECT_PREFIX-jenkins $2:5000/hellgate75/$PROJECT_PREFIX-jenkins &&  docker push $2:5000/hellgate75/$PROJECT_PREFIX-jenkins && docker rmi -f hellgate75/$PROJECT_PREFIX-jenkins"
  ## connect to leader, download Nexus3 source, build Jenkins docker images and push Jenkins docker image on leader docker registry
  echo "Provisioning $PROJECT_PREFIX-nexus docker image"
  docker-machine ssh $1 "cd ./nexus3 && docker build --rm --force-rm --no-cache --tag hellgate75/$PROJECT_PREFIX-nexus . && docker tag hellgate75/$PROJECT_PREFIX-nexus $2:5000/hellgate75/$PROJECT_PREFIX-nexus && docker push $2:5000/hellgate75/$PROJECT_PREFIX-nexus && docker rmi -f hellgate75/$PROJECT_PREFIX-nexus"
  ## connect to sonarqube worker docker-machine, and pull mysql docker image from docker hub libraries (faster stack creation)
  ## connect to leader, download SonarQube source, build Jenkins docker images and push Jenkins docker image on leader docker registry
  echo "Provisioning $PROJECT_PREFIX-sonarqube docker image"
  docker-machine ssh $1 "docker pull mysql:5.7"
  docker-machine ssh $1 "cd ./sonarqube && docker build --rm --force-rm --no-cache --tag hellgate75/$PROJECT_PREFIX-sonarqube . && docker tag hellgate75/$PROJECT_PREFIX-sonarqube $2:5000/hellgate75/$PROJECT_PREFIX-sonarqube && docker push $2:5000/hellgate75/$PROJECT_PREFIX-sonarqube && docker rmi -f hellgate75/$PROJECT_PREFIX-sonarqube"
}

##########################################################################
## Export docker image to filesystem                                    ##
## Parameters :                                                         ##
##   - local path (string) [NOT nullable]                               ##
##   - Suffix (string) [NOT nullable]                                   ##
##   - LEADER IP (string) [NOT nullable]                                ##
##   - docker image qualifier (string) [NOT nullable]                   ##
##         eg.: jenkins, nexus, sonarqube                               ##
##   - Docker Machine full name (string) [NOT nullable]                 ##
## Returns:                                                             ##
##   (none)                                                             ##
##########################################################################
function exportContinuousDeliveryDockerImage() {
  mkdir -p $1/docker-images
  rm -f $1/docker-images/$ENVIRONMENT-$4$2.tar
  docker save --output $1/docker-images/$ENVIRONMENT-$4$2.tar $3:5000/hellgate75/$PROJECT_PREFIX-$4
}

##########################################################################
## Copy exported docker image to docker machine                         ##
## Parameters :                                                         ##
##   - local path (string) [NOT nullable]                               ##
##   - Suffix (string) [NOT nullable]                                   ##
##   - LEADER IP (string) [NOT nullable]                                ##
##   - docker image qualifier (string) [NOT nullable]                   ##
##         eg.: jenkins, nexus, sonarqube                               ##
##   - Docker Machine full name (string) [NOT nullable]                 ##
## Returns:                                                             ##
##   (none)                                                             ##
##########################################################################
function copyAndInstallImageFromDockerMachine() {
  docker-machine ssh $5 "mkdir -p /var/lib/home/docker/swarm/docker-images && rm -f /var/lib/home/docker/swarm/docker-images/$ENVIRONMENT-$4$2.tar"
  docker-machine scp $1/docker-images/$ENVIRONMENT-$4$2.tar $5:/var/lib/home/docker/swarm/docker-images/$ENVIRONMENT-$4$2.tar
  docker-machine ssh $5 "docker load --quiet --input /var/lib/home/docker/swarm/docker-images/$ENVIRONMENT-$4$2.tar"
}

##########################################################################
## Copy exported docker image to docker machine                         ##
## Parameters :                                                         ##
##   - local path (string) [NOT nullable]                               ##
##   - Suffix (string) [NOT nullable]                                   ##
##   - LEADER IP (string) [NOT nullable]                                ##
##   - docker image qualifier (string) [NOT nullable]                   ##
##         eg.: jenkins, nexus, sonarqube                               ##
##   - Docker Machine full name (string) [NOT nullable]                 ##
## Returns:                                                             ##
##   (none)                                                             ##
##########################################################################
function copyAndInstallImageLocalDockerMachine() {
  docker-machine ssh $5 "mkdir -p /var/lib/home/docker/swarm/docker-images && rm -f /var/lib/home/docker/swarm/docker-images/$ENVIRONMENT-$4$2.tar"
  docker-machine ssh $5 "cp $1/docker-images/$ENVIRONMENT-$4$2.tar /var/lib/home/docker/swarm/docker-images/$ENVIRONMENT-$4$2.tar"
  docker-machine ssh $5 "docker load --quiet --input /var/lib/home/docker/swarm/docker-images/$ENVIRONMENT-$4$2.tar"
}
