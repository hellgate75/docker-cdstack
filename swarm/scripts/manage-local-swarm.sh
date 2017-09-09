#!/bin/bash

##########################################################################
## Execute Swarm Cluser operations with script parameters:              ##
##  - command (--create|--destory|--start|--stop|--redeploy)            ##
##  - suffix (suffix for docker-machine name)                           ##
##########################################################################
if [[ "--destroy" == "$1" ]]; then
  ## Destroy Swarm cluster vm nodes
  ## Required :
  ##   (none)
  ## Optional :
  ##   - Docker Machine Suffix name
  echo "$(logo)"
  echo "Destroying Swarm nodes environment ..."
  SUFFIX="$(checkSuffix $2)"
  echo "Using suffix : $(echo "$SUFFIX" | sed 's/^-//g')"
  docker-machine rm -f $PROJECT_PREFIX-jenkins$SUFFIX $PROJECT_PREFIX-nexus$SUFFIX $PROJECT_PREFIX-sonarqube$SUFFIX $PROJECT_PREFIX-leader$SUFFIX
  exit 0
elif [[ "--stop" == "$1" ]]; then
  ## Stop Swarm cluster vm nodes
  ## Required :
  ##   (none)
  ## Optional :
  ##   - Docker Machine Suffix name
  echo "$(logo)"
  echo "Stopping Swarm nodes environment ..."
  SUFFIX="$(checkSuffix $2)"
  echo "Using suffix : $(echo "$SUFFIX" | sed 's/^-//g')"
  docker-machine stop $PROJECT_PREFIX-jenkins$SUFFIX $PROJECT_PREFIX-nexus$SUFFIX $PROJECT_PREFIX-sonarqube$SUFFIX $PROJECT_PREFIX-leader$SUFFIX
  exit 0
elif [[ "--start" == "$1" ]]; then
  ## Start Swarm cluster vm nodes
  ## Required :
  ##   (none)
  ## Optional :
  ##   - Docker Machine Suffix name
  echo "$(logo)"
  echo "Starting Swarm nodes environment ..."
  SUFFIX="$(checkSuffix $2)"
  echo "Using suffix : $(echo "$SUFFIX" | sed 's/^-//g')"
  RESTARTED_JENKINS="0"
  RESTARTED_NEXUS="0"
  RESTARTED_SONAR="0"
  if ! [[ -z "$(docker-machine ls|grep $PROJECT_PREFIX-leader$SUFFIX)" ]]; then
    if [[ -z "$(docker-machine ls|grep $PROJECT_PREFIX-leader$SUFFIX|grep Running)" ]]; then
      docker-machine start $PROJECT_PREFIX-leader$SUFFIX

      LEADER_IP="$(docker-machine ip $PROJECT_PREFIX-leader$SUFFIX)"

      remountDockerInSolidVolume "$PROJECT_PREFIX-leader$SUFFIX"

      docker-machine restart $PROJECT_PREFIX-leader$SUFFIX

      sleep 5

      LEADER_IP="$(docker-machine ip $PROJECT_PREFIX-leader$SUFFIX)"

      remountDockerLibHomeSolidVolume "$PROJECT_PREFIX-leader$SUFFIX"

      echo "$(installLocalCertificates "/hosthome/swarm-local"  "$PROJECT_PREFIX-leader$SUFFIX" "$LEADER_IP")"

      ## Copying swarm stack source folder ...
      docker-machine ssh $PROJECT_PREFIX-leader$SUFFIX "cp -Rf /hosthome/swarm-local /home/docker/swarm"
      docker-machine ssh $PROJECT_PREFIX-leader$SUFFIX "sed -i \"s/hellgate75/$LEADER_IP:5000\\\/hellgate75/g\" swarm/docker-compose-cdservice.yml && sed -i \"s/CDSTACK_PROJECT_NAME/$PROJECT_PREFIX/g\" swarm/docker-compose-cdservice.yml"
      docker-machine ssh $PROJECT_PREFIX-leader$SUFFIX "sed -i \"s/mysql:5.7/$LEADER_IP:5000\\\/hellgate75\\\/mysql:5.7/g\" swarm/docker-compose-cdservice.yml"
      docker-machine ssh $PROJECT_PREFIX-leader$SUFFIX "sed -i \"s/CDSTACK_PROJECT_NAME/$PROJECT_PREFIX/g\" swarm/docker-compose-registry.yml"
      ## Copying source folder for further deployment ...
       echo "$(copySourceFolders "$PROJECT_PREFIX-leader$SUFFIX" "$DOCKER_FOLDER_PATH")"
    else
      LEADER_IP="$(docker-machine ip $PROJECT_PREFIX-leader$SUFFIX)"
      echo "WARNING : Leader Swardocker-machine ssh $PROJECT_PREFIX-leader$SUFFIX "cp -Rf /hosthome/swarm-local /home/docker/swarm"m cluster node is running yet. Nothing to do!!"
    fi
  else
    echo "ERROR : Leader Swarm cluster node doesn't exists please destroy and recreate Swarm Cluster!!"
    exit 1
  fi
  if ! [[ -z "$(docker-machine ls|grep $PROJECT_PREFIX-jenkins$SUFFIX)" ]]; then
    if [[ -z "$(docker-machine ls|grep $PROJECT_PREFIX-jenkins$SUFFIX|grep Running)" ]]; then
      docker-machine start $PROJECT_PREFIX-jenkins$SUFFIX
      ## Local docker-machine Swarm Cluster
      if [[ -z "$LEADER_IP" ]]; then
        LEADER_IP="$(docker-machine ip $PROJECT_PREFIX-leader$SUFFIX)"
      fi

      remountDockerInSolidVolume "$PROJECT_PREFIX-jenkins$SUFFIX"

      docker-machine restart $PROJECT_PREFIX-jenkins$SUFFIX

      sleep 5

      remountDockerLibHomeSolidVolume "$PROJECT_PREFIX-jenkins$SUFFIX"

      echo "$(installLocalCertificates "/hosthome/swarm-local"  "$PROJECT_PREFIX-jenkins$SUFFIX" "$LEADER_IP")"
      RESTARTED_JENKINS="1"
    else
      echo "WARNING : Jenkins Swarm cluster node is running yet. Nothing to do!!"
    fi
  else
    echo "ERROR : Jenkins Swarm cluster node doesn't exists please destroy and recreate Swarm Cluster!!"
    exit 1
  fi
  if ! [[ -z "$(docker-machine ls|grep $PROJECT_PREFIX-nexus$SUFFIX)" ]]; then
    if [[ -z "$(docker-machine ls|grep $PROJECT_PREFIX-nexus$SUFFIX|grep Running)" ]]; then
      docker-machine start $PROJECT_PREFIX-nexus$SUFFIX
      ## Local docker-machine Swarm Cluster
      if [[ -z "$LEADER_IP" ]]; then
        LEADER_IP="$(docker-machine ip $PROJECT_PREFIX-leader$SUFFIX)"
      fi

      remountDockerInSolidVolume "$PROJECT_PREFIX-nexus$SUFFIX"

      docker-machine restart $PROJECT_PREFIX-nexus$SUFFIX

      sleep 5

      remountDockerLibHomeSolidVolume "$PROJECT_PREFIX-nexus$SUFFIX"

      echo "$(installLocalCertificates "/hosthome/swarm-local"  "$PROJECT_PREFIX-nexus$SUFFIX" "$LEADER_IP")"
      RESTARTED_NEXUS="1"
    else
      echo "WARNING : Nexus 3 OSS Swarm cluster node is running yet. Nothing to do!!"
    fi
  else
    echo "ERROR : Nexus 3 OSS Swarm cluster node doesn't exists please destroy and recreate Swarm Cluster!!"
    exit 1
  fi
  if ! [[ -z "$(docker-machine ls|grep $PROJECT_PREFIX-sonarqube$SUFFIX)" ]]; then
    if [[ -z "$(docker-machine ls|grep $PROJECT_PREFIX-sonarqube$SUFFIX|grep Running)" ]]; then
      docker-machine start $PROJECT_PREFIX-sonarqube$SUFFIX
      ## Local docker-machine Swarm Cluster
      if [[ -z "$LEADER_IP" ]]; then
        LEADER_IP="$(docker-machine ip $PROJECT_PREFIX-leader$SUFFIX)"
      fi

      remountDockerInSolidVolume "$PROJECT_PREFIX-sonarqube$SUFFIX"

      docker-machine restart $PROJECT_PREFIX-sonarqube$SUFFIX

      sleep 5

      remountDockerLibHomeSolidVolume "$PROJECT_PREFIX-sonarqube$SUFFIX"

      echo "$(installLocalCertificates "/hosthome/swarm-local"  "$PROJECT_PREFIX-sonarqube$SUFFIX" "$LEADER_IP")"
      RESTARTED_SONAR="1"
    else
      echo "WARNING : SonarQube Swarm cluster node is running yet. Nothing to do!!"
    fi
  else
    echo "ERROR : SonarQube Swarm cluster node doesn't exists please destroy and recreate Swarm Cluster!!"
    exit 1
  fi
  ## if any of nodes is restarted advertise about Swarm cluster capabilities and dependencies
  if [[ "1" == "$RESTARTED_JENKINS" || "1" == "$RESTARTED_NEXUS" || "1" == "$RESTARTED_SONAR" ]]; then
    echo "$(advertise "$SUFFIX" "$LEADER_IP")"
  fi
  exit 0
elif [[ "--create" == "$1" ]]; then
  ## Create first time Swarm cluster vm nodes
  ## Required :
  ##   (none)
  ## Optional :
  ##   - Docker Machine Suffix name
  FORCE_REBUILD="0"
  echo "$(logo)"
  echo "Creating Swarm nodes environment ..."
  if [[ "--force-rebuild" == "$2" ]]; then
    FORCE_REBUILD="1"
  fi
  if [[ $# -gt 2 ]]; then
    SUFFIX="$(checkSuffix $3)"
  else
    SUFFIX="$(checkSuffix $2)"
  fi
  echo "Using suffix : $(echo "$SUFFIX" | sed 's/^-//g')"
  ## Local docker-machine Swarm Cluster
  LEADER_MEMORY="${SWARM_LOCAL_LEADER_MEMORY:-"1024"}" #1 GB
  LEADER_DISK="${SWARM_LOCAL_LEADER_DISK:-"50000"}" #50 GB
  LEADER_CUPS="${SWARM_LOCAL_LEADER_CUPS:-"1"}"
  JENKINS_MEMORY="${SWARM_LOCAL_JENKINS_MEMORYS:-"1024"}" #1 GB
  JENKINS_DISK="${SWARM_LOCAL_JENKINS_DISK:-"30000"}" #30 GB
  JENKINS_CUPS="${SWARM_LOCAL_JENKINS_CUPS:-"1"}"
  NEXUS_MEMORY="${SWARM_LOCAL_NEXUS_MEMORY:-"1024"}" #1 GB
  NEXUS_DISK="${SWARM_LOCAL_NEXUS_DISK:-"30000"}" #30 GB
  NEXUS_CUPS="${SWARM_LOCAL_NEXUS_CUPS:-"1"}"
  SONAR_MEMORY="${SWARM_LOCAL_SONAR_MEMORY:-"2560"}" #2.5 GB
  SONAR_DISK="${SWARM_LOCAL_SONAR_DISK:-"40000"}" #40 GB
  SONAR_CUPS="${SWARM_LOCAL_SONAR_CUPS:-"2"}"
  DOCKER_COMPOSE_VERSION="1.15.0"
  PROVISION_JENKINS="0"
  PROVISION_NEXUS="0"
  PROVISION_SONAR="0"
  if [[ -z "$(docker-machine ls | grep $PROJECT_PREFIX-leader$SUFFIX)" ]]; then
    echo "Creating Swarm Master : $PROJECT_PREFIX-leader$SUFFIX ..."
    echo "Memory : $LEADER_MEMORY MB"
    echo "Disk : $LEADER_DISK MB"
    echo "CPUs : $LEADER_CUPS"
    docker-machine create --driver "virtualbox" --engine-insecure-registry "http://$LEADER_IP:5000" --engine-opt experimental=true \
                          --engine-label projectnodename=leader --virtualbox-memory "$LEADER_MEMORY" --virtualbox-disk-size "$LEADER_DISK" \
                          --virtualbox-cpu-count "$LEADER_CUPS" --virtualbox-share-folder "$(pwd):hosthome" $PROJECT_PREFIX-leader$SUFFIX
    createDockerInSolidVolume "$PROJECT_PREFIX-leader$SUFFIX"

    docker-machine restart $PROJECT_PREFIX-leader$SUFFIX

    sleep 5

    mountDockerLibHomeSolidVolume "$PROJECT_PREFIX-leader$SUFFIX"

    LEADER_IP="$(docker-machine ip $PROJECT_PREFIX-leader$SUFFIX)"

    ## Join Swarm Cluster
    docker-machine ssh $PROJECT_PREFIX-leader$SUFFIX "docker swarm init --advertise-addr $LEADER_IP"

    ## Adjust local docker registry reference on docker config and restart docker
    docker-machine ssh $PROJECT_PREFIX-leader$SUFFIX "sudo sed -i \"s/insecure-registry http:\\/\\/.*/insecure-registry http:\\\/\\\/$LEADER_IP:5000/g\" /var/lib/boot2docker/profile"
    docker-machine ssh $PROJECT_PREFIX-leader$SUFFIX "sed -i \"s/CDSTACK_PROJECT_NAME/$PROJECT_PREFIX/g\" swarm/docker-compose-registry.yml"
    docker-machine ssh  $PROJECT_PREFIX-leader$SUFFIX "sudo /etc/init.d/docker restart"

    sleep 5
    NEED_CERTIFICATE="1"
    if [[ -e $(pwd)/swarm-local/.certificate-ip && "$LEADER_IP" == "$(cat $(pwd)/swarm-local/.certificate-ip)" ]]; then
      NEED_CERTIFICATE="0"
    fi
    if [[ "1" == "$NEED_CERTIFICATE" ]]; then
      ## Rebuild SSL certificates for docker-registry
      echo "Now rebuild certificates for docker registry. Please use as FQDN, the leader ip address : \"$LEADER_IP\""
      bash -c "cd $(pwd)/swarm-local && $(pwd)/swarm-local/make-certificate.sh"
      echo "$LEADER_IP" > $(pwd)/swarm-local/.certificate-ip
      wait
    else
      ## Rebuild SSL certificates for docker-registry
      echo "Valid certificate found for leader on ip address : \"$LEADER_IP\""
    fi

    echo "$(installLocalCertificates "/hosthome/swarm-local"  "$PROJECT_PREFIX-leader$SUFFIX" "$LEADER_IP")"

    sleep 5

    ## Register qualification Swarm Node label on Swarm Cluster Leader docker-machine (used by app comose to define placement of instances)
    docker-machine ssh $PROJECT_PREFIX-leader$SUFFIX "docker node update --label-add projectnodename=leader $PROJECT_PREFIX-leader$SUFFIX"

    ## create swarm folder on leader Swarm Cluster docker-machine, pull portainer.io docker image from Docker Hub librraries, and deploy portainer stack on Swarm Cluster (only on leader node)
    echo "Creating Portainer.IO on Swarm Master : $PROJECT_PREFIX-leader$SUFFIX ..."
    docker-machine ssh $PROJECT_PREFIX-leader$SUFFIX "cp -Rf /hosthome/swarm-local /home/docker/swarm"
    docker-machine ssh $PROJECT_PREFIX-leader$SUFFIX "docker pull portainer/portainer"
    docker-machine ssh $PROJECT_PREFIX-leader$SUFFIX "docker deploy -c ./swarm/docker-compose-portainer.yml --resolve-image \"always\" --prune $PROJECT_PREFIX-cdmainstack"
    echo "Provisioning Swarm Master : $PROJECT_PREFIX-leader ..."

    docker-machine ssh $PROJECT_PREFIX-leader$SUFFIX "sed -i \"s/CDSTACK_PROJECT_NAME/$PROJECT_PREFIX/g\" swarm/docker-compose-registry.yml"

    ## create docker registry folder on leader Swarm Cluster docker-machine, copy all configuration and security file in that folder, pull docker registy v2 docker image from Docker Hub librraries, and deploy docker registry stack on Swarm Cluster (only on leader node)
    docker-machine ssh $PROJECT_PREFIX-leader$SUFFIX "mkdir -p /home/docker/registry"
    docker-machine ssh $PROJECT_PREFIX-leader$SUFFIX "cp /hosthome/swarm-local/registry.yml /home/docker/registry/config.yml"
    docker-machine ssh $PROJECT_PREFIX-leader$SUFFIX "cp /hosthome/swarm-local/htpasswd /home/docker/registry/htpasswd"
    docker-machine ssh $PROJECT_PREFIX-leader$SUFFIX "cp /hosthome/swarm-local/domain.crt /home/docker/registry/domain.crt"
    docker-machine ssh $PROJECT_PREFIX-leader$SUFFIX "cp /hosthome/swarm-local/domain.key /home/docker/registry/domain.key"
    docker-machine ssh $PROJECT_PREFIX-leader$SUFFIX "docker pull registry:2"

    ## Deploy rehistry stack
    echo "Creating Docker registry v2 on Swarm Master : $PROJECT_PREFIX-leader$SUFFIX ..."
    docker-machine ssh $PROJECT_PREFIX-leader$SUFFIX "docker deploy -c ./swarm/docker-compose-registry.yml --resolve-image \"always\" --prune $PROJECT_PREFIX-cdregistrystack"

    sleep 10

    ## Fill in Continuous Delivery deployment stack docker registry reference for worker local docker push
    docker-machine ssh $PROJECT_PREFIX-leader$SUFFIX "sed -i \"s/hellgate75/$LEADER_IP:5000\\\/hellgate75/g\" swarm/docker-compose-cdservice.yml && sed -i \"s/CDSTACK_PROJECT_NAME/$PROJECT_PREFIX/g\" swarm/docker-compose-cdservice.yml"
    docker-machine ssh $PROJECT_PREFIX-leader$SUFFIX "sed -i \"s/mysql:5.7/$LEADER_IP:5000\\\/hellgate75\\\/mysql:5.7/g\" swarm/docker-compose-cdservice.yml"
    docker-machine ssh $PROJECT_PREFIX-leader$SUFFIX "sed -i \"s/CDSTACK_PROJECT_NAME/$PROJECT_PREFIX/g\" swarm/docker-compose-registry.yml"


    AUTHORIZATION_TOKEN="$(curl -H 'Content-Type: application/json' -X POST -d '{"username":"admin","password":"admin123"}' http://$LEADER_IP:9091/api/auth|awk 'BEGIN {FS=OFS=":"}{print $2}'|awk 'BEGIN {FS=OFS="\""}{print $2}')"
    ## Configure main profile endpoint on local machine host.
    docker-machine ssh $PROJECT_PREFIX-leader$SUFFIX "export TOKEN=\"$AUTHORIZATION_TOKEN\" && curl -H \"Authorization: Bearer \$TOKEN\" -H 'Content-Type: application/json' -X POST -d \"{\\\"Name\\\":\\\"leader$SUFFIX\\\",\\\"URL\\\":\\\"unix:\\\/\\\/\\\/var\\\/run\\\/docker.sock\\\",\\\"TLS\\\":false}\" http://$LEADER_IP:9091/api/endpoints"
    ## Configure local docker registry on Portainer.IO using authorised POST call
    docker-machine ssh $PROJECT_PREFIX-leader$SUFFIX "export TOKEN=\"$AUTHORIZATION_TOKEN\" && curl -H \"Authorization: Bearer \$TOKEN\" -H 'Content-Type: application/json' -X POST -d \"{\\\"Name\\\":\\\"local\\\",\\\"URL\\\":\\\"$LEADER_IP:5000\\\",\\\"Authentication\\\":true,\\\"Username\\\":\\\"admin\\\",\\\"Password\\\":\\\"admin\\\"}\" http://$LEADER_IP:9091/api/registries"
    ## Definition of standard user (role: 2), in case of definition of administrator role value must be 1
    docker-machine ssh $PROJECT_PREFIX-leader$SUFFIX "export TOKEN=\"$AUTHORIZATION_TOKEN\" && curl -H \"Authorization: Bearer \$TOKEN\" -H 'Content-Type: application/json' -X POST -d \"{\\\"username\\\":\\\"$PORTAINER_STD_USER_NAME\\\",\\\"password\\\":\\\"$PORTAINER_STD_USER_NAME\\\",\\\"role\\\":2}\" http://$LEADER_IP:9091/api/users"
    ## Changing admin password
    docker-machine ssh $PROJECT_PREFIX-leader$SUFFIX "export TOKEN=\"$AUTHORIZATION_TOKEN\" && curl -H \"Authorization: Bearer \$TOKEN\" -H 'Content-Type: application/json' -X PUT -d \"{\\\"password\\\":\\\"$PORTAINER_ADMIN_PASSWORD\\\"}\" http://$LEADER_IP:9091/api/users/1"
  else
    LEADER_IP="$(docker-machine ip $PROJECT_PREFIX-leader$SUFFIX)"
    ## Using fake user and password, just for web access .... Authentication is via X509 certificate
    # REGISTRY_LOGIN="echo \"admin\" | docker login --username admin --password-stdin  http://$LEADER_IP:5000"
    # docker-machine ssh $PROJECT_PREFIX-leader$SUFFIX "echo \"$REGISTRY_LOGIN\" >> /home/docker/.profile"
    echo "Swarm Master : $PROJECT_PREFIX-leader already exists"
  fi


  eval $(docker-machine env $PROJECT_PREFIX-jenkins$SUFFIX)
  if [[ -z "$(docker-machine ls | grep $PROJECT_PREFIX-jenkins$SUFFIX)" ]]; then
    echo "Creating Swarm Worker : $PROJECT_PREFIX-jenkins$SUFFIX ..."
    echo "Memory : $JENKINS_MEMORY MB"
    echo "Disk : $JENKINS_DISK MB"
    echo "CPUs : $JENKINS_CUPS"
    docker-machine create --driver "virtualbox" --engine-insecure-registry "http://$LEADER_IP:5000" --engine-opt experimental=true \
                          --engine-label projectnodename=jenkins --virtualbox-memory "$JENKINS_MEMORY" --virtualbox-disk-size "$JENKINS_DISK" \
                          --virtualbox-cpu-count "$JENKINS_CUPS" --virtualbox-share-folder "$(pwd):hosthome"  $PROJECT_PREFIX-jenkins$SUFFIX

    createDockerInSolidVolume "$PROJECT_PREFIX-jenkins$SUFFIX"

    docker-machine restart $PROJECT_PREFIX-jenkins$SUFFIX

    sleep 5

    mountDockerLibHomeSolidVolume "$PROJECT_PREFIX-jenkins$SUFFIX"

    ## Register Swarm worker node on Swarm Cluster Leader docker-machine
    TOKEN_COMMAND="$(docker-machine ssh $PROJECT_PREFIX-leader$SUFFIX "docker swarm join-token worker"|grep docker)"
    docker-machine ssh $PROJECT_PREFIX-jenkins$SUFFIX "eval $TOKEN_COMMAND"

    PROVISION_JENKINS="1"

    echo "$(installLocalCertificates "/hosthome/swarm-local"  "$PROJECT_PREFIX-jenkins$SUFFIX" "$LEADER_IP")"

    sleep 5

    ## Register qualification Swarm Node label on Swarm Cluster Leader docker-machine (used by app comose to define placement of instances)
    docker-machine ssh $PROJECT_PREFIX-leader$SUFFIX "docker node update --label-add projectnodename=jenkins $PROJECT_PREFIX-jenkins$SUFFIX"

  else
    # REGISTRY_LOGIN="echo \"admin\" | docker login --username admin --password-stdin  http://$LEADER_IP:5000"
    # docker-machine ssh $PROJECT_PREFIX-jenkins$SUFFIX "echo \"$REGISTRY_LOGIN\" >> /home/docker/.profile"
    echo "Swarm Worker : $PROJECT_PREFIX-jenkins already exists"
  fi
  if [[ -z "$(docker-machine ls | grep $PROJECT_PREFIX-nexus$SUFFIX)" ]]; then
    echo "Creating Swarm Worker : $PROJECT_PREFIX-nexus$SUFFIX ..."
    echo "Memory : $NEXUS_MEMORY MB"
    echo "Disk : $NEXUS_DISK MB"
    echo "CPUs : $NEXUS_CUPS"
    docker-machine create --driver "virtualbox" --engine-insecure-registry "http://$LEADER_IP:5000" --engine-opt experimental=true \
                          --engine-label projectnodename=nexus3 --virtualbox-memory "$NEXUS_MEMORY" --virtualbox-disk-size "$NEXUS_DISK" \
                          --virtualbox-cpu-count "$NEXUS_CUPS" --virtualbox-share-folder "$(pwd):hosthome"  $PROJECT_PREFIX-nexus$SUFFIX

    createDockerInSolidVolume "$PROJECT_PREFIX-nexus$SUFFIX"

    docker-machine restart $PROJECT_PREFIX-nexus$SUFFIX

    sleep 5

    mountDockerLibHomeSolidVolume "$PROJECT_PREFIX-nexus$SUFFIX"

    ## Register Swarm worker node on Swarm Cluster Leader docker-machine
    TOKEN_COMMAND="$(docker-machine ssh $PROJECT_PREFIX-leader$SUFFIX "docker swarm join-token worker"|grep docker)"
    docker-machine ssh $PROJECT_PREFIX-nexus$SUFFIX "eval $TOKEN_COMMAND"
    PROVISION_NEXUS="1"

    echo "$(installLocalCertificates "/hosthome/swarm-local"  "$PROJECT_PREFIX-nexus$SUFFIX" "$LEADER_IP")"

    sleep 5

    ## Check Nexus docker container volumes backup archive presence on disk and eventually download a new archive from Amazon S3
    if ! [[ -e ./archives/samples_nexus3_data.tgz  ]]; then
      mkdir -p ./archives
      curl -L https://s3-eu-west-1.amazonaws.com/ftorelli-docker-configuration/continuous-delivery/volumes/samples_nexus3_data.tgz -o ./archives/samples_nexus3_data.tgz
    fi
    ## Create Nexus archive remote folder, copy archive file on docker-machine and restore archive in a new volume, used by docker container
    docker-machine ssh $PROJECT_PREFIX-nexus$SUFFIX "mkdir -p /var/lib/home/docker/swarm/archives"
    docker-machine ssh $PROJECT_PREFIX-nexus$SUFFIX "cp /hosthome/archives/samples_nexus3_data.tgz /var/lib/home/docker/swarm/archives/samples_nexus3_data.tgz"
    # docker-machine scp ./archives/samples_nexus3_data.tgz $PROJECT_PREFIX-nexus$SUFFIX:/var/lib/home/docker/swarm/archives/samples_nexus3_data.tgz
    docker-machine ssh $PROJECT_PREFIX-nexus$SUFFIX "docker volume create \"samples_nexus3_data\" && docker run --rm -i -v \"samples_nexus3_data:/volume\" -v \"/var/lib/home/docker/swarm/archives:/backup\" ubuntu:16.10 bash -c \"rm -Rf /volume/*; tar -xzf /backup/samples_nexus3_data.tgz -C /volume\""

    sleep 5

    ## Register qualification Swarm Node label on Swarm Cluster Leader docker-machine (used by app comose to define placement of instances)
    docker-machine ssh $PROJECT_PREFIX-leader$SUFFIX "docker node update --label-add projectnodename=nexus3 $PROJECT_PREFIX-nexus$SUFFIX"
  else
    # REGISTRY_LOGIN="echo \"admin\" | docker login --username admin --password-stdin  http://$LEADER_IP:5000"
    # docker-machine ssh $PROJECT_PREFIX-nexus$SUFFIX "echo \"$REGISTRY_LOGIN\" >> /home/docker/.profile"
    echo "Swarm Worker : $PROJECT_PREFIX-nexus already exists"
  fi

  if [[ -z "$(docker-machine ls | grep $PROJECT_PREFIX-sonarqube$SUFFIX)" ]]; then
    echo "Creating Swarm Worker : $PROJECT_PREFIX-sonarqube$SUFFIX ..."
    echo "Memory : $SONAR_MEMORY MB"
    echo "Disk : $SONAR_DISK MB"
    echo "CPUs : $SONAR_CUPS"
    docker-machine create --driver "virtualbox" --engine-insecure-registry "http://$LEADER_IP:5000" --engine-opt experimental=true \
                          --engine-label projectnodename=sonarqube --virtualbox-memory "$SONAR_MEMORY" --virtualbox-disk-size "$SONAR_DISK" \
                          --virtualbox-cpu-count "$SONAR_CUPS" --virtualbox-share-folder "$(pwd):hosthome"  $PROJECT_PREFIX-sonarqube$SUFFIX

    createDockerInSolidVolume "$PROJECT_PREFIX-sonarqube$SUFFIX"

    docker-machine restart $PROJECT_PREFIX-sonarqube$SUFFIX

    sleep 5

    mountDockerLibHomeSolidVolume "$PROJECT_PREFIX-sonarqube$SUFFIX"

    ## Register Swarm worker node on Swarm Cluster Leader docker-machine
    TOKEN_COMMAND="$(docker-machine ssh $PROJECT_PREFIX-leader$SUFFIX "docker swarm join-token worker"|grep docker)"
    docker-machine ssh $PROJECT_PREFIX-sonarqube$SUFFIX "eval $TOKEN_COMMAND"
    PROVISION_SONAR="1"

    echo "$(installLocalCertificates "/hosthome/swarm-local"  "$PROJECT_PREFIX-sonarqube$SUFFIX" "$LEADER_IP")"


    sleep 5

    ## Check SonarQube and SonarQube Database docker container volumes backup archives presence on disk and eventually download new archives from Amazon S3
    if ! [[ -e ./archives/samples_sonarqube_data.tgz  ]]; then
      mkdir -p ./archives
      curl -L https://s3-eu-west-1.amazonaws.com/ftorelli-docker-configuration/continuous-delivery/volumes/samples_sonarqube_data.tgz -o ./archives/samples_sonarqube_data.tgz
    fi
    if ! [[ -e ./archives/samples_sonarqube_db_data.tgz  ]]; then
      mkdir -p ./archives
      curl -L https://s3-eu-west-1.amazonaws.com/ftorelli-docker-configuration/continuous-delivery/volumes/samples_sonarqube_db_data.tgz -o ./archives/samples_sonarqube_db_data.tgz
    fi
    ## Create SonarQube and SonarQube archives remote folder, copy archive files on docker-machine and restore archives in new volumes, used by docker containers
    docker-machine ssh $PROJECT_PREFIX-sonarqube$SUFFIX "mkdir -p /var/lib/home/docker/swarm/archives"
    docker-machine ssh $PROJECT_PREFIX-sonarqube$SUFFIX "cp /hosthome/archives/samples_sonarqube_data.tgz /var/lib/home/docker/swarm/archives/samples_sonarqube_data.tgz"
    docker-machine ssh $PROJECT_PREFIX-sonarqube$SUFFIX "cp /hosthome/archives/samples_sonarqube_db_data.tgz /var/lib/home/docker/swarm/archives/samples_sonarqube_db_data.tgz"
    # docker-machine scp ./archives/samples_sonarqube_data.tgz $PROJECT_PREFIX-sonarqube$SUFFIX:/var/lib/home/docker/swarm/archives/samples_sonarqube_data.tgz
    # docker-machine scp ./archives/samples_sonarqube_db_data.tgz $PROJECT_PREFIX-sonarqube$SUFFIX:/var/lib/home/docker/swarm/archives/samples_sonarqube_db_data.tgz
    docker-machine ssh $PROJECT_PREFIX-sonarqube$SUFFIX "docker volume create \"samples_sonarqube_data\" && docker run --rm -i -v \"samples_sonarqube_data:/volume\" -v \"/var/lib/home/docker/swarm/archives:/backup\" ubuntu:16.10 bash -c \"rm -Rf /volume/*; tar -xzf /backup/samples_sonarqube_data.tgz -C /volume\""
    sleep 20
    docker-machine ssh $PROJECT_PREFIX-sonarqube$SUFFIX "docker volume create \"samples_sonarqube_db_data\" && docker run --rm -i -v \"samples_sonarqube_db_data:/volume\" -v \"/var/lib/home/docker/swarm/archives:/backup\" ubuntu:16.10 bash -c \"rm -Rf /volume/*; tar -xzf /backup/samples_sonarqube_db_data.tgz -C /volume\""


    sleep 5

    ## Register qualification Swarm Node label on Swarm Cluster Leader docker-machine (used by app comose to define placement of instances)
    docker-machine ssh $PROJECT_PREFIX-leader$SUFFIX "docker node update --label-add projectnodename=sonarqube $PROJECT_PREFIX-sonarqube$SUFFIX"
  else
    # REGISTRY_LOGIN="echo \"admin\" | docker login --username admin --password-stdin  http://$LEADER_IP:5000"
    # docker-machine ssh $PROJECT_PREFIX-sonarqube$SUFFIX "echo \"$REGISTRY_LOGIN\" >> /home/docker/.profile"
    echo "Swarm Worker : $PROJECT_PREFIX-sonarqube already exists"
  fi
  ## if all docker worker machines has been created, connect to leader, download sources, build docker images and push all docker images on leader docker registry
  if [[ "1" == "$PROVISION_JENKINS" && "1" == "$PROVISION_NEXUS" && "1" == "$PROVISION_SONAR" ]]; then
    ## Copying source folder for docker image build ...
     echo "$(copySourceFolders "$PROJECT_PREFIX-leader$SUFFIX" "$DOCKER_FOLDER_PATH")"

    ## Build docker images
    echo "Building Docker images and pushing them to the local registry."
    echo "Please wait since docker build and push complete ..."
    # echo "$(buildCDDockerImages "$PROJECT_PREFIX-leader$SUFFIX" "$LEADER_IP")"
    echo "Building $PROJECT_PREFIX-jenkins$SUFFIX docker image"
    if [[ -z "$(docker images|grep "$LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-jenkins")" ]]; then
      ## Local tag for repository doesn't exist ...
      if [[ "1" == "$FORCE_REBUILD" || -z "$(docker images|grep "hellgate75/$PROJECT_PREFIX-jenkins")"  ]]; then
        ## Force build of local docker image and create a tag for remote repository ...
        FORCE_REBUILD="1"
        echo "Force Rebuild $PROJECT_PREFIX-jenkins docker image ..."

        if ! [[ -z "$(docker images|grep "hellgate75/$PROJECT_PREFIX-jenkins")" ]]; then
          ## Remove docker image
          docker images|grep "hellgate75/$PROJECT_PREFIX-jenkins"|awk 'BEGIN {FS=OFS=" "}{print $3}'|xargs docker rmi -f
        fi
        ## rebuild and tag new docker image for Jenkins
        echo "Building docker image ..."
        bash -c "cd $DOCKER_FOLDER_PATH/jenkins && docker build --rm --force-rm --no-cache --tag hellgate75/$PROJECT_PREFIX-jenkins . && docker tag hellgate75/$PROJECT_PREFIX-jenkins $LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-jenkins"
        wait
      else
        bash -c "docker tag hellgate75/$PROJECT_PREFIX-jenkins $LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-jenkins"
        wait
      fi
      if [[ "1" == "$FORCE_REBUILD" || ! -e ./docker-images/$ENVIRONMENT-jenkins$SUFFIX.tar ]]; then
        echo "Exporting docker image \"$LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-jenkins\" locally ..."
        echo "Please wait for process to complete ..."
        exportContinuousDeliveryDockerImage "$(pwd)" "$SUFFIX" "$LEADER_IP" "jenkins"
      else
        echo "Jenkins docker image export already exists ..."
      fi
      echo "Copying docker image archive to Leader and installing \"$LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-jenkins\" remotely ..."
      echo "Please wait for process to complete ..."
      copyAndInstallImageLocalDockerMachine "/hosthome" "$SUFFIX" "$LEADER_IP" "jenkins" "$PROJECT_PREFIX-leader$SUFFIX"
      echo "Pushing docker image \"$LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-jenkins\" to remote repository ..."
      docker-machine ssh $PROJECT_PREFIX-leader$SUFFIX "docker push $LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-jenkins"

    else
      ## Local tag for repository does exist ...
      echo "Local Jenkins image tag exists"
      if [[ "1" == "$FORCE_REBUILD" || -z "$(docker images|grep "hellgate75/$PROJECT_PREFIX-jenkins")" ]]; then
        ## Force build of local docker image and create a tag for remote repository ...
        FORCE_REBUILD="1"
        echo "Force Rebuild $PROJECT_PREFIX-jenkins docker image ..."

        ## Remove previous registry tag
        echo "Removing local docker image tag ..."
        docker images|grep "$LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-jenkins"|awk 'BEGIN {FS=OFS=" "}{print $3}'|xargs docker rmi -f

        if ! [[ -z "$(docker images|grep "hellgate75/$PROJECT_PREFIX-jenkins")" ]]; then
          ## Remove docker image
          echo "Removing local docker image ..."
          docker images|grep "hellgate75/$PROJECT_PREFIX-jenkins"|awk 'BEGIN {FS=OFS=" "}{print $3}'|xargs docker rmi -f
        fi
        ## rebuild and tag new docker image for Jenkins
        echo "Building docker image ..."
        bash -c "cd $DOCKER_FOLDER_PATH/jenkins && docker build --rm --force-rm --no-cache --tag hellgate75/$PROJECT_PREFIX-jenkins . && docker tag hellgate75/$PROJECT_PREFIX-jenkins $LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-jenkins"
        wait
      fi
      if [[ "1" == "$FORCE_REBUILD" || ! -e ./docker-images/$ENVIRONMENT-jenkins$SUFFIX.tar ]]; then
        echo "Exporting docker image \"$LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-jenkins\" locally ..."
        echo "Please wait for process to complete ..."
        exportContinuousDeliveryDockerImage "$(pwd)" "$SUFFIX" "$LEADER_IP" "jenkins"
      else
        echo "Jenkins docker image export already exists ..."
      fi
      echo "Copying docker image archive to Leader and installing \"$LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-jenkins\" remotely ..."
      echo "Please wait for process to complete ..."
      copyAndInstallImageLocalDockerMachine "/hosthome" "$SUFFIX" "$LEADER_IP" "jenkins" "$PROJECT_PREFIX-leader$SUFFIX"
      echo "Pushing docker image \"$LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-jenkins\" to remote repository ..."
      docker-machine ssh $PROJECT_PREFIX-leader$SUFFIX "docker push $LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-jenkins"
    fi
    ## connect to leader, download Nexus3 source, build Jenkins docker images and push Jenkins docker image on leader docker registry
    echo "Building $PROJECT_PREFIX-nexus$SUFFIX docker image"
    if [[ -z "$(docker images|grep "$LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-nexus")" ]]; then
      ## Local tag for repository doesn't exist ...
      if [[ "1" == "$FORCE_REBUILD" || -z "$(docker images|grep "hellgate75/$PROJECT_PREFIX-nexus")" ]]; then
        ## Force build of local docker image and create a tag for remote repository ...
        FORCE_REBUILD="1"
        echo "Force Rebuild $PROJECT_PREFIX-nexus docker image ..."

        if ! [[ -z "$(docker images|grep "hellgate75/$PROJECT_PREFIX-nexus")" ]]; then
          ## Remove docker image
          docker images|grep "hellgate75/$PROJECT_PREFIX-nexus"|awk 'BEGIN {FS=OFS=" "}{print $3}'|xargs docker rmi -f
        fi
        ## rebuild and tag new docker image for Jenkins
        echo "Building docker image ..."
        bash -c "cd $DOCKER_FOLDER_PATH/nexus3 && docker build --rm --force-rm --no-cache --tag hellgate75/$PROJECT_PREFIX-nexus . && docker tag hellgate75/$PROJECT_PREFIX-nexus $LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-nexus"
        wait
      else
        bash -c "docker tag hellgate75/$PROJECT_PREFIX-nexus $LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-nexus"
        wait
      fi
      if [[ "1" == "$FORCE_REBUILD" || ! -e ./docker-images/$ENVIRONMENT-nexus$SUFFIX.tar ]]; then
        echo "Exporting docker image \"$LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-nexus\" locally ..."
        echo "Please wait for process to complete ..."
        exportContinuousDeliveryDockerImage "$(pwd)" "$SUFFIX" "$LEADER_IP" "nexus"
      else
        echo "Nexus 3 docker image export already exists ..."
      fi
      echo "Copying docker image archive to Leader and installing \"$LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-nexus\" remotely ..."
      echo "Please wait for process to complete ..."
      copyAndInstallImageLocalDockerMachine "/hosthome" "$SUFFIX" "$LEADER_IP" "nexus" "$PROJECT_PREFIX-leader$SUFFIX"
      echo "Pushing docker image \"$LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-nexus\" to remote repository ..."
      docker-machine ssh $PROJECT_PREFIX-leader$SUFFIX "docker push $LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-nexus"

    else
      ## Local tag for repository does exist ...
      echo "Local Nexus 3 image tag exists"
      if [[ "1" == "$FORCE_REBUILD" || -z "$(docker images|grep "hellgate75/$PROJECT_PREFIX-nexus")" ]]; then
        ## Force build of local docker image and create a tag for remote repository ...
        FORCE_REBUILD="1"
        echo "Force Rebuild $PROJECT_PREFIX-nexus docker image ..."

        ## Remove previous registry tag
        echo "Removing local docker image tag ..."
        docker images|grep "$LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-nexus"|awk 'BEGIN {FS=OFS=" "}{print $3}'|xargs docker rmi -f

        if ! [[ -z "$(docker images|grep "hellgate75/$PROJECT_PREFIX-nexus")" ]]; then
          ## Remove docker image
          echo "Removing local docker image ..."
          docker images|grep "hellgate75/$PROJECT_PREFIX-nexus"|awk 'BEGIN {FS=OFS=" "}{print $3}'|xargs docker rmi -f
        fi
        ## rebuild and tag new docker image for Jenkins
        echo "Building docker image ..."
        bash -c "cd $DOCKER_FOLDER_PATH/nexus3 && docker build --rm --force-rm --no-cache --tag hellgate75/$PROJECT_PREFIX-nexus . && docker tag hellgate75/$PROJECT_PREFIX-nexus $LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-nexus"
        wait
      fi
      if [[ "1" == "$FORCE_REBUILD" || ! -e ./docker-images/$ENVIRONMENT-nexus$SUFFIX.tar ]]; then
        echo "Exporting docker image \"$LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-nexus\" locally ..."
        echo "Please wait for process to complete ..."
        exportContinuousDeliveryDockerImage "$(pwd)" "$SUFFIX" "$LEADER_IP" "nexus"
      else
        echo "Nexus 3 docker image export already exists ..."
      fi
      echo "Copying docker image archive to Leader and installing \"$LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-nexus\" remotely ..."
      echo "Please wait for process to complete ..."
      copyAndInstallImageLocalDockerMachine "/hosthome" "$SUFFIX" "$LEADER_IP" "nexus" "$PROJECT_PREFIX-leader$SUFFIX"
      echo "Pushing docker image \"$LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-nexus\" to remote repository ..."
      docker-machine ssh $PROJECT_PREFIX-leader$SUFFIX "docker push $LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-nexus"
    fi
    ## connect to sonarqube worker docker-machine, and pull mysql docker image from docker hub libraries (faster stack creation)
    echo "Building $PROJECT_PREFIX-sonarqube$SUFFIX docker images"
    docker-machine ssh $PROJECT_PREFIX-leader$SUFFIX "docker pull mysql:5.7"
    docker-machine ssh $PROJECT_PREFIX-leader$SUFFIX "docker tag mysql:5.7 $LEADER_IP:5000/hellgate75/mysql:5.7"
    docker-machine ssh $PROJECT_PREFIX-leader$SUFFIX "docker push $LEADER_IP:5000/hellgate75/mysql:5.7"
    if [[ -z "$(docker images|grep "$LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-sonarqube")" ]]; then
      ## Local tag for repository doesn't exist ...
      if [[ "1" == "$FORCE_REBUILD" || -z "$(docker images|grep "hellgate75/$PROJECT_PREFIX-sonarqube")" ]]; then
        ## Force build of local docker image and create a tag for remote repository ...
        FORCE_REBUILD="1"
        echo "Force Rebuild $PROJECT_PREFIX-sonarqube docker image ..."

        if ! [[ -z "$(docker images|grep "hellgate75/$PROJECT_PREFIX-sonarqube")" ]]; then
          ## Remove docker image
          docker images|grep "hellgate75/$PROJECT_PREFIX-sonarqube"|awk 'BEGIN {FS=OFS=" "}{print $3}'|xargs docker rmi -f
        fi
        ## rebuild and tag new docker image for Jenkins
        echo "Building docker image ..."
        bash -c "cd $DOCKER_FOLDER_PATH/sonarqube && docker build --rm --force-rm --no-cache --tag hellgate75/$PROJECT_PREFIX-sonarqube . && docker tag hellgate75/$PROJECT_PREFIX-sonarqube $LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-sonarqube"
        wait
      else
        bash -c "docker tag hellgate75/$PROJECT_PREFIX-sonarqube $LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-sonarqube"
        wait
      fi
      if [[ "1" == "$FORCE_REBUILD" || ! -e ./docker-images/$ENVIRONMENT-sonarqube$SUFFIX.tar ]]; then
        echo "Exporting docker image \"$LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-sonarqube\" locally ..."
        echo "Please wait for process to complete ..."
        exportContinuousDeliveryDockerImage "$(pwd)" "$SUFFIX" "$LEADER_IP" "sonarqube"
      else
        echo "SonarQube docker image export already exists ..."
      fi
      echo "Copying docker image archive to Leader and installing \"$LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-sonarqube\" remotely ..."
      echo "Please wait for process to complete ..."
      copyAndInstallImageLocalDockerMachine "/hosthome" "$SUFFIX" "$LEADER_IP" "sonarqube" "$PROJECT_PREFIX-leader$SUFFIX"
      echo "Pushing docker image \"$LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-sonarqube\" to remote repository ..."
      docker-machine ssh $PROJECT_PREFIX-leader$SUFFIX "docker push $LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-sonarqube"

    else
      ## Local tag for repository does exist ...
      echo "Local SonarQube image tag exists"
      if [[ "1" == "$FORCE_REBUILD" || -z "$(docker images|grep "hellgate75/$PROJECT_PREFIX-sonarqube")" ]]; then
        ## Force build of local docker image and create a tag for remote repository ...
        FORCE_REBUILD="1"
        echo "Force Rebuild $PROJECT_PREFIX-sonarqube docker image ..."

        ## Remove previous registry tag
        echo "Removing local docker image tag ..."
        docker images|grep "$LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-sonarqube"|awk 'BEGIN {FS=OFS=" "}{print $3}'|xargs docker rmi -f

        if ! [[ -z "$(docker images|grep "hellgate75/$PROJECT_PREFIX-sonarqube")" ]]; then
          ## Remove docker image
          echo "Removing local docker image ..."
          docker images|grep "hellgate75/$PROJECT_PREFIX-sonarqube"|awk 'BEGIN {FS=OFS=" "}{print $3}'|xargs docker rmi -f
        fi
        ## rebuild and tag new docker image for Jenkins
        echo "Building docker image ..."
        bash -c "cd $DOCKER_FOLDER_PATH/sonarqube && docker build --rm --force-rm --no-cache --tag hellgate75/$PROJECT_PREFIX-sonarqube . && docker tag hellgate75/$PROJECT_PREFIX-sonarqube $LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-sonarqube"
        wait
      fi
      if [[ "1" == "$FORCE_REBUILD" || ! -e ./docker-images/$ENVIRONMENT-sonarqube$SUFFIX.tar ]]; then
        echo "Exporting docker image \"$LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-sonarqube\" locally ..."
        echo "Please wait for process to complete ..."
        exportContinuousDeliveryDockerImage "$(pwd)" "$SUFFIX" "$LEADER_IP" "sonarqube"
      else
        echo "SonarQube docker image export already exists ..."
      fi
      echo "Copying docker image archive to Leader and installing \"$LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-sonarqube\" remotely ..."
      echo "Please wait for process to complete ..."
      copyAndInstallImageLocalDockerMachine "/hosthome" "$SUFFIX" "$LEADER_IP" "sonarqube" "$PROJECT_PREFIX-leader$SUFFIX"
      echo "Pushing docker image \"$LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-sonarqube\" to remote repository ..."
      docker-machine ssh $PROJECT_PREFIX-leader$SUFFIX "docker push $LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-sonarqube"
    fi

    ## create continuous delivery stack on Swarm cluster, connecting to leader (manager) node
    echo "Creating cd service stack ..."
    docker-machine ssh $PROJECT_PREFIX-leader$SUFFIX "docker deploy -c ./swarm/docker-compose-cdservice.yml --resolve-image \"always\" $PROJECT_PREFIX-cdservice"
  fi

  ## advertise about Swarm cluster capabilities and dependencies
  echo "$(advertise "$SUFFIX" "$LEADER_IP")"
  exit 0
elif [[ "--redeploy" == "$1" ]]; then
  ## Create first time Swarm cluster vm nodes
  ## Required :
  ##   (none)
  ## Optional :
  ##   - rebuild parameter
  ##   - force docker image built
  ##   - Docker Machine Suffix name
  echo "$(logo)"
  echo "Redeploy CD on Swarm nodes environment ..."
  REBUILD="0"
  COPYYAML="0"
  FORCE_REBUILD="0"
  if [[ "--rebuild" == "$2" ]]; then
    REBUILD="1"
  fi
  if [[ "--copyyaml" == "$2" ]]; then
    COPYYAML="1"
  fi
  if [[ "--force-rebuild" == "$2" ]]; then
    FORCE_REBUILD="1"
  fi
  if [[ "--rebuild" == "$3" ]]; then
    REBUILD="1"
  fi
  if [[ "--copyyaml" == "$3" ]]; then
    COPYYAML="1"
  fi
  if [[ "--force-rebuild" == "$3" ]]; then
    FORCE_REBUILD="1"
  fi
  if [[ "--rebuild" == "$4" ]]; then
    REBUILD="1"
  fi
  if [[ "--copyyaml" == "$4" ]]; then
    COPYYAML="1"
  fi
  if [[ "--force-rebuild" == "$4" ]]; then
    FORCE_REBUILD="1"
  fi
  if [[ $# -gt 4 ]]; then
    SUFFIX="$(checkSuffix $5)"
  elif [[ $# -gt 3 ]]; then
    SUFFIX="$(checkSuffix $4)"
  elif [[ $# -gt 3 ]]; then
    SUFFIX="$(checkSuffix $3)"
  else
    SUFFIX="$(checkSuffix $2)"
  fi

  echo "Using suffix : $(echo "$SUFFIX" | sed 's/^-//g')"
  if  [[ "1" == "$REBUILD" ]]; then
    REBUILD_FLAG="yes"
  else
    REBUILD_FLAG="no"
  fi
  echo "Rebuild docker images : $REBUILD_FLAG"

  if  [[ "1" == "$FORCE_REBUILD" ]]; then
    FORCE_REBUILD_FLAG="yes"
  else
    FORCE_REBUILD_FLAG="no"
  fi
  echo "Force rebuild local docker images : $FORCE_REBUILD_FLAG"

  if  [[ "1" == "$COPYYAML" ]]; then
    COPYYAML_FLAG="yes"
  else
    COPYYAML_FLAG="no"
  fi
  echo "Copy Swarm Script folder : $COPYYAML_FLAG"

  LEADER_IP="$(docker-machine ip $PROJECT_PREFIX-leader$SUFFIX)"

  if  [[ "1" == "$REBUILD" ]]; then
    ## Copying source folder for docker image rebuild ...
     echo "$(copySourceFolders "$PROJECT_PREFIX-leader$SUFFIX" "$DOCKER_FOLDER_PATH")"

    ## Build docker images
    echo "Building Docker images and pushing them to the local registry."
    echo "Please wait since docker build and push complete ..."
    # echo "$(buildCDDockerImages "$PROJECT_PREFIX-leader$SUFFIX" "$LEADER_IP")"
    echo "Building $PROJECT_PREFIX-jenkins$SUFFIX docker image"
    if [[ -z "$(docker images|grep "$LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-jenkins")" ]]; then
      ## Local tag for repository doesn't exist ...
      if [[ "1" == "$FORCE_REBUILD" || -z "$(docker images|grep "hellgate75/$PROJECT_PREFIX-jenkins")"  ]]; then
        ## Force build of local docker image and create a tag for remote repository ...
        FORCE_REBUILD="1"
        echo "Force Rebuild $PROJECT_PREFIX-jenkins docker image ..."

        if ! [[ -z "$(docker images|grep "hellgate75/$PROJECT_PREFIX-jenkins")" ]]; then
          ## Remove docker image
          docker images|grep "hellgate75/$PROJECT_PREFIX-jenkins"|awk 'BEGIN {FS=OFS=" "}{print $3}'|xargs docker rmi -f
        fi
        ## rebuild and tag new docker image for Jenkins
        echo "Building docker image ..."
        bash -c "cd $DOCKER_FOLDER_PATH/jenkins && docker build --rm --force-rm --no-cache --tag hellgate75/$PROJECT_PREFIX-jenkins . && docker tag hellgate75/$PROJECT_PREFIX-jenkins $LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-jenkins"
        wait
      else
        bash -c "docker tag hellgate75/$PROJECT_PREFIX-jenkins $LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-jenkins"
        wait
      fi
      if [[ "1" == "$FORCE_REBUILD" || ! -e ./docker-images/$ENVIRONMENT-jenkins$SUFFIX.tar ]]; then
        echo "Exporting docker image \"$LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-jenkins\" locally ..."
        echo "Please wait for process to complete ..."
        exportContinuousDeliveryDockerImage "$(pwd)" "$SUFFIX" "$LEADER_IP" "jenkins"
      else
        echo "Jenkins docker image export already exists ..."
      fi
      echo "Copying docker image archive to Leader and installing \"$LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-jenkins\" remotely ..."
      echo "Please wait for process to complete ..."
      copyAndInstallImageLocalDockerMachine "/hosthome" "$SUFFIX" "$LEADER_IP" "jenkins" "$PROJECT_PREFIX-leader$SUFFIX"
      echo "Pushing docker image \"$LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-jenkins\" to remote repository ..."
      docker-machine ssh $PROJECT_PREFIX-leader$SUFFIX "docker push $LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-jenkins"

    else
      ## Local tag for repository does exist ...
      echo "Local Jenkins image tag exists"
      if [[ "1" == "$FORCE_REBUILD" || -z "$(docker images|grep "hellgate75/$PROJECT_PREFIX-jenkins")" ]]; then
        ## Force build of local docker image and create a tag for remote repository ...
        FORCE_REBUILD="1"
        echo "Force Rebuild $PROJECT_PREFIX-jenkins docker image ..."

        ## Remove previous registry tag
        echo "Removing local docker image tag ..."
        docker images|grep "$LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-jenkins"|awk 'BEGIN {FS=OFS=" "}{print $3}'|xargs docker rmi -f

        if ! [[ -z "$(docker images|grep "hellgate75/$PROJECT_PREFIX-jenkins")" ]]; then
          ## Remove docker image
          echo "Removing local docker image ..."
          docker images|grep "hellgate75/$PROJECT_PREFIX-jenkins"|awk 'BEGIN {FS=OFS=" "}{print $3}'|xargs docker rmi -f
        fi
        ## rebuild and tag new docker image for Jenkins
        echo "Building docker image ..."
        bash -c "cd $DOCKER_FOLDER_PATH/jenkins && docker build --rm --force-rm --no-cache --tag hellgate75/$PROJECT_PREFIX-jenkins . && docker tag hellgate75/$PROJECT_PREFIX-jenkins $LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-jenkins"
        wait
      fi
      if [[ "1" == "$FORCE_REBUILD" || ! -e ./docker-images/$ENVIRONMENT-jenkins$SUFFIX.tar ]]; then
        echo "Exporting docker image \"$LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-jenkins\" locally ..."
        echo "Please wait for process to complete ..."
        exportContinuousDeliveryDockerImage "$(pwd)" "$SUFFIX" "$LEADER_IP" "jenkins"
      else
        echo "Jenkins docker image export already exists ..."
      fi
      echo "Copying docker image archive to Leader and installing \"$LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-jenkins\" remotely ..."
      echo "Please wait for process to complete ..."
      copyAndInstallImageLocalDockerMachine "/hosthome" "$SUFFIX" "$LEADER_IP" "jenkins" "$PROJECT_PREFIX-leader$SUFFIX"
      echo "Pushing docker image \"$LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-jenkins\" to remote repository ..."
      docker-machine ssh $PROJECT_PREFIX-leader$SUFFIX "docker push $LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-jenkins"
    fi
    # docker-machine ssh $PROJECT_PREFIX-leader$SUFFIX "cd ./jenkins && docker build --rm --force-rm --no-cache --tag hellgate75/$PROJECT_PREFIX-jenkins . && docker tag hellgate75/$PROJECT_PREFIX-jenkins $LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-jenkins &&  docker push $LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-jenkins && docker rmi -f hellgate75/$PROJECT_PREFIX-jenkins"
    ## connect to leader, download Nexus3 source, build Jenkins docker images and push Jenkins docker image on leader docker registry
    echo "Building $PROJECT_PREFIX-nexus$SUFFIX docker image"
    if [[ -z "$(docker images|grep "$LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-nexus")" ]]; then
      ## Local tag for repository doesn't exist ...
      if [[ "1" == "$FORCE_REBUILD" || -z "$(docker images|grep "hellgate75/$PROJECT_PREFIX-nexus")" ]]; then
        ## Force build of local docker image and create a tag for remote repository ...
        FORCE_REBUILD="1"
        echo "Force Rebuild $PROJECT_PREFIX-nexus docker image ..."

        if ! [[ -z "$(docker images|grep "hellgate75/$PROJECT_PREFIX-nexus")" ]]; then
          ## Remove docker image
          docker images|grep "hellgate75/$PROJECT_PREFIX-nexus"|awk 'BEGIN {FS=OFS=" "}{print $3}'|xargs docker rmi -f
        fi
        ## rebuild and tag new docker image for Jenkins
        echo "Building docker image ..."
        bash -c "cd $DOCKER_FOLDER_PATH/nexus3 && docker build --rm --force-rm --no-cache --tag hellgate75/$PROJECT_PREFIX-nexus . && docker tag hellgate75/$PROJECT_PREFIX-nexus $LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-nexus"
        wait
      else
        bash -c "docker tag hellgate75/$PROJECT_PREFIX-nexus $LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-nexus"
        wait
      fi
      if [[ "1" == "$FORCE_REBUILD" || ! -e ./docker-images/$ENVIRONMENT-nexus$SUFFIX.tar ]]; then
        echo "Exporting docker image \"$LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-nexus\" locally ..."
        echo "Please wait for process to complete ..."
        exportContinuousDeliveryDockerImage "$(pwd)" "$SUFFIX" "$LEADER_IP" "nexus"
      else
        echo "Nexus 3 docker image export already exists ..."
      fi
      echo "Copying docker image archive to Leader and installing \"$LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-nexus\" remotely ..."
      echo "Please wait for process to complete ..."
      copyAndInstallImageLocalDockerMachine "/hosthome" "$SUFFIX" "$LEADER_IP" "nexus" "$PROJECT_PREFIX-leader$SUFFIX"
      echo "Pushing docker image \"$LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-nexus\" to remote repository ..."
      docker-machine ssh $PROJECT_PREFIX-leader$SUFFIX "docker push $LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-nexus"

    else
      ## Local tag for repository does exist ...
      echo "Local Nexus 3 image tag exists"
      if [[ "1" == "$FORCE_REBUILD" || -z "$(docker images|grep "hellgate75/$PROJECT_PREFIX-nexus")" ]]; then
        ## Force build of local docker image and create a tag for remote repository ...
        FORCE_REBUILD="1"
        echo "Force Rebuild $PROJECT_PREFIX-nexus docker image ..."

        ## Remove previous registry tag
        echo "Removing local docker image tag ..."
        docker images|grep "$LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-nexus"|awk 'BEGIN {FS=OFS=" "}{print $3}'|xargs docker rmi -f

        if ! [[ -z "$(docker images|grep "hellgate75/$PROJECT_PREFIX-nexus")" ]]; then
          ## Remove docker image
          echo "Removing local docker image ..."
          docker images|grep "hellgate75/$PROJECT_PREFIX-nexus"|awk 'BEGIN {FS=OFS=" "}{print $3}'|xargs docker rmi -f
        fi
        ## rebuild and tag new docker image for Jenkins
        echo "Building docker image ..."
        bash -c "cd $DOCKER_FOLDER_PATH/nexus3 && docker build --rm --force-rm --no-cache --tag hellgate75/$PROJECT_PREFIX-nexus . && docker tag hellgate75/$PROJECT_PREFIX-nexus $LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-nexus"
        wait
      fi
      if [[ "1" == "$FORCE_REBUILD" || ! -e ./docker-images/$ENVIRONMENT-nexus$SUFFIX.tar ]]; then
        echo "Exporting docker image \"$LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-nexus\" locally ..."
        echo "Please wait for process to complete ..."
        exportContinuousDeliveryDockerImage "$(pwd)" "$SUFFIX" "$LEADER_IP" "nexus"
      else
        echo "Nexus 3 docker image export already exists ..."
      fi
      echo "Copying docker image archive to Leader and installing \"$LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-nexus\" remotely ..."
      echo "Please wait for process to complete ..."
      copyAndInstallImageLocalDockerMachine "/hosthome" "$SUFFIX" "$LEADER_IP" "nexus" "$PROJECT_PREFIX-leader$SUFFIX"
      echo "Pushing docker image \"$LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-nexus\" to remote repository ..."
      docker-machine ssh $PROJECT_PREFIX-leader$SUFFIX "docker push $LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-nexus"
    fi
    # docker-machine ssh $PROJECT_PREFIX-leader$SUFFIX "cd ./nexus3 && docker build --rm --force-rm --no-cache --tag hellgate75/$PROJECT_PREFIX-nexus . && docker tag hellgate75/$PROJECT_PREFIX-nexus $LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-nexus && docker push $LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-nexus && docker rmi -f hellgate75/$PROJECT_PREFIX-nexus"
    ## connect to sonarqube worker docker-machine, and pull mysql docker image from docker hub libraries (faster stack creation)
      echo "Building $PROJECT_PREFIX-sonarqube$SUFFIX docker images"
    docker-machine ssh $PROJECT_PREFIX-leader$SUFFIX "docker pull mysql:5.7"
    docker-machine ssh $PROJECT_PREFIX-leader$SUFFIX "docker tag mysql:5.7 $LEADER_IP:5000/hellgate75/mysql:5.7"
    docker-machine ssh $PROJECT_PREFIX-leader$SUFFIX "docker push $LEADER_IP:5000/hellgate75/mysql:5.7"
    if [[ -z "$(docker images|grep "$LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-sonarqube")" ]]; then
      ## Local tag for repository doesn't exist ...
      if [[ "1" == "$FORCE_REBUILD" || -z "$(docker images|grep "hellgate75/$PROJECT_PREFIX-sonarqube")" ]]; then
        ## Force build of local docker image and create a tag for remote repository ...
        FORCE_REBUILD="1"
        echo "Force Rebuild $PROJECT_PREFIX-sonarqube docker image ..."

        if ! [[ -z "$(docker images|grep "hellgate75/$PROJECT_PREFIX-sonarqube")" ]]; then
          ## Remove docker image
          docker images|grep "hellgate75/$PROJECT_PREFIX-sonarqube"|awk 'BEGIN {FS=OFS=" "}{print $3}'|xargs docker rmi -f
        fi
        ## rebuild and tag new docker image for Jenkins
        echo "Building docker image ..."
        bash -c "cd $DOCKER_FOLDER_PATH/sonarqube && docker build --rm --force-rm --no-cache --tag hellgate75/$PROJECT_PREFIX-sonarqube . && docker tag hellgate75/$PROJECT_PREFIX-sonarqube $LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-sonarqube"
        wait
      else
        bash -c "docker tag hellgate75/$PROJECT_PREFIX-sonarqube $LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-sonarqube"
        wait
      fi
      if [[ "1" == "$FORCE_REBUILD" || ! -e ./docker-images/$ENVIRONMENT-sonarqube$SUFFIX.tar ]]; then
        echo "Exporting docker image \"$LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-sonarqube\" locally ..."
        echo "Please wait for process to complete ..."
        exportContinuousDeliveryDockerImage "$(pwd)" "$SUFFIX" "$LEADER_IP" "sonarqube"
      else
        echo "SonarQube docker image export already exists ..."
      fi
      echo "Copying docker image archive to Leader and installing \"$LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-sonarqube\" remotely ..."
      echo "Please wait for process to complete ..."
      copyAndInstallImageLocalDockerMachine "/hosthome" "$SUFFIX" "$LEADER_IP" "sonarqube" "$PROJECT_PREFIX-leader$SUFFIX"
      echo "Pushing docker image \"$LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-sonarqube\" to remote repository ..."
      docker-machine ssh $PROJECT_PREFIX-leader$SUFFIX "docker push $LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-sonarqube"

    else
      ## Local tag for repository does exist ...
      echo "Local SonarQube image tag exists"
      if [[ "1" == "$FORCE_REBUILD" || -z "$(docker images|grep "hellgate75/$PROJECT_PREFIX-sonarqube")" ]]; then
        ## Force build of local docker image and create a tag for remote repository ...
        FORCE_REBUILD="1"
        echo "Force Rebuild $PROJECT_PREFIX-sonarqube docker image ..."

        ## Remove previous registry tag
        echo "Removing local docker image tag ..."
        docker images|grep "$LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-sonarqube"|awk 'BEGIN {FS=OFS=" "}{print $3}'|xargs docker rmi -f

        if ! [[ -z "$(docker images|grep "hellgate75/$PROJECT_PREFIX-sonarqube")" ]]; then
          ## Remove docker image
          echo "Removing local docker image ..."
          docker images|grep "hellgate75/$PROJECT_PREFIX-sonarqube"|awk 'BEGIN {FS=OFS=" "}{print $3}'|xargs docker rmi -f
        fi
        ## rebuild and tag new docker image for Jenkins
        echo "Building docker image ..."
        bash -c "cd $DOCKER_FOLDER_PATH/sonarqube && docker build --rm --force-rm --no-cache --tag hellgate75/$PROJECT_PREFIX-sonarqube . && docker tag hellgate75/$PROJECT_PREFIX-sonarqube $LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-sonarqube"
        wait
      fi
      if [[ "1" == "$FORCE_REBUILD" || ! -e ./docker-images/$ENVIRONMENT-sonarqube$SUFFIX.tar ]]; then
        echo "Exporting docker image \"$LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-sonarqube\" locally ..."
        echo "Please wait for process to complete ..."
        exportContinuousDeliveryDockerImage "$(pwd)" "$SUFFIX" "$LEADER_IP" "sonarqube"
      else
        echo "SonarQube docker image export already exists ..."
      fi
      echo "Copying docker image archive to Leader and installing \"$LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-sonarqube\" remotely ..."
      echo "Please wait for process to complete ..."
      copyAndInstallImageLocalDockerMachine "/hosthome" "$SUFFIX" "$LEADER_IP" "sonarqube" "$PROJECT_PREFIX-leader$SUFFIX"
      echo "Pushing docker image \"$LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-sonarqube\" to remote repository ..."
      docker-machine ssh $PROJECT_PREFIX-leader$SUFFIX "docker push $LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-sonarqube"
    fi
    # docker-machine ssh $PROJECT_PREFIX-leader$SUFFIX "cd ./sonarqube && docker build --rm --force-rm --no-cache --tag hellgate75/$PROJECT_PREFIX-sonarqube . && docker tag hellgate75/$PROJECT_PREFIX-sonarqube $LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-sonarqube && docker push $LEADER_IP:5000/hellgate75/$PROJECT_PREFIX-sonarqube && docker rmi -f hellgate75/$PROJECT_PREFIX-sonarqube"
  fi
  if  [[ "1" == "$COPYYAML_FLAG" ]]; then
    ## Copying swarm script source folder for docker stack rebuild ...
    docker-machine ssh $PROJECT_PREFIX-leader$SUFFIX "cp -Rf /hosthome/swarm-local /home/docker/swarm"
    ## Fill in Continuous Delivery deployment stack docker registry reference for worker local docker push
    docker-machine ssh $PROJECT_PREFIX-leader$SUFFIX "sed -i \"s/hellgate75/$LEADER_IP:5000\\\/hellgate75/g\" swarm/docker-compose-cdservice.yml && sed -i \"s/CDSTACK_PROJECT_NAME/$PROJECT_PREFIX/g\" swarm/docker-compose-cdservice.yml"
    docker-machine ssh $PROJECT_PREFIX-leader$SUFFIX "sed -i \"s/mysql:5.7/$LEADER_IP:5000\\\/hellgate75\\\/mysql:5.7/g\" swarm/docker-compose-cdservice.yml"
    docker-machine ssh $PROJECT_PREFIX-leader$SUFFIX "sed -i \"s/CDSTACK_PROJECT_NAME/$PROJECT_PREFIX/g\" swarm/docker-compose-registry.yml"
  fi
  ## redeploy continuous delivery stack on Swarm cluster, connecting to leader (manager) node
  echo "Creating cd service stack ..."
  docker-machine ssh $PROJECT_PREFIX-leader$SUFFIX "docker stack deploy -c ./swarm/docker-compose-cdservice.yml --resolve-image \"always\" $PROJECT_PREFIX-cdservice"
else
  echo "$(usage)"
  exit 1
fi
