#!/bin/bash

##########################################################################
## Execute Kubernetes Cluster operations with script parameters:        ##
##  - command (--create|--destory|--start|--stop|--redeploy)            ##
##  - suffix (suffix for docker-machine name)                           ##
##########################################################################


if [[ "0" == "$(isVirtualBoxInstalled)" ]]; then
  echo "Oracle VirtualBox seems not installed. We cannot proceed...\nPlease fix it and relunch your command!!"
  exit 1
fi

if [[ "0" == "$(isLinuxOS)" ]]; then
  echo "This operating system is not a Linux One. We cannot give warranty on installation instructions we need!!"
  echo "If you cannot install it via automated shell script, please install kunectl kubeadm helm minikube manually."
fi

echo "Now checking required tools we need for managing Kubernetes Cluster..."
installMinikube
installKubectl
installHelm
installKubetools


KUBERNETES_OPERABLE="$(isKubernetOperable)"
if [[ "0" == "$KUBERNETES_OPERABLE" ]]; then
  echo "Required tools we need for managing Kubernetes Cluster are not installed!!"
  echo "If you cannot install it via automated shell script, please install kunectl kubeadm helm minikube manually."
  exit 1
fi


KUBERNETES_STATUS="0"
if [[ "1 1 1" ==  $(kubernetesStatus) ]]; then
  KUBERNETES_STATUS="1"
fi

KUBERNETES_CLUSTER_INSTALLED="0"
if [[ -e $(pwd)/kubernetes-local/.kubestate ]]; then
  KUBERNETES_CLUSTER_INSTALLED="1"
fi

if [[ "--destroy" == "$1" ]]; then
  ## Destroy Kubernetes cluster vm nodes
  ## Required :
  ##   (none)
  ## Optional :
  ##   - Docker Machine Suffix name
  echo "$(logo)"
  echo "Environment: $ENVIRONMENT"
  echo "Destroying Kubernetes Cluster environment ..."
 if [[ "0" == "$KUBERNETES_CLUSTER_INSTALLED" ]]; then
   echo -e "WARNING: Kubernetes cluster applications not installed!!\nPlease run \"--create\" option as first..."
   echo -e "\nExiting ..."
   exit 0
 fi
 SUFFIX="$(checkSuffix $2)"
  echo "Using suffix : $(echo "$SUFFIX" | sed 's/^-//g')"
  minikube delete
  EXIT_STATE="$?"
  rm -f $(pwd)/kubernetes-local/.kubestate
  exit $EXIT_STATE
elif [[ "--stop" == "$1" ]]; then
  ## Stop Kubernetes cluster vm nodes
  ## Required :
  ##   (none)
  ## Optional :
  ##   - Docker Machine Suffix name
  echo "$(logo)"
  echo "Environment: $ENVIRONMENT"
  echo "Stopping Kubernetes Cluster environment ..."
  if [[ "0" == "$KUBERNETES_CLUSTER_INSTALLED" ]]; then
    echo -e "WARNING: Kubernetes cluster applications not installed!!\nPlease run \"--create\" option as first..."
    echo -e "\nExiting ..."
    exit 0
  fi
  if [[ "0" == "$KUBERNETES_STATUS" ]]; then
    echo -e "WARNING: Kubernetes cluster not running or failing!!\nIf it doesn't sound good for you please start or destroy cluster.\nYou can check cluster status running \"minikube status\""
    echo -e "\nExiting ..."
    exit 0
  fi
  SUFFIX="$(checkSuffix $2)"
  echo "Using suffix : $(echo "$SUFFIX" | sed 's/^-//g')"
  minikube stop
  EXIT_STATE="$?"
  exit $EXIT_STATE
elif [[ "--start" == "$1" ]]; then
  ## Start Kubernetes cluster vm nodes
  ## Required :
  ##   (none)
  ## Optional :
  ##   - Docker Machine Suffix name
  echo "$(logo)"
  echo "Environment: $ENVIRONMENT"
  echo "Starting Kubernetes Cluster environment ..."
  if [[ "0" == "$KUBERNETES_CLUSTER_INSTALLED" ]]; then
    echo -e "WARNING: Kubernetes cluster applications not installed!!\nPlease run \"--create\" option as first..."
    echo -e "\nExiting ..."
    exit 0
  fi
  if [[ "1" == "$KUBERNETES_STATUS" ]]; then
    echo -e "WARNING: Kubernetes cluster already running!!\nIf it doesn't sound good for you please stop or destroy cluster.\nYou can check cluster status running \"minikube status\""
    echo -e "\nExiting ..."
    exit 0
  fi
  SUFFIX="$(checkSuffix $2)"
  echo "Using suffix : $(echo "$SUFFIX" | sed 's/^-//g')"
  startMinikubeAndHelm
  EXIT_STATE="$?"
  echo "$EXIT_STATE"
  startDashboard
  exit $EXIT_STATE
elif [[ "--create" == "$1" ]]; then
  ## Create first time Kubernetes cluster vm nodes
  ## Required :
  ##   (none)
  ## Optional :
  ##   - Docker Machine Suffix name
  FORCE_REBUILD="0"
  echo "$(logo)"
  echo "Environment: $ENVIRONMENT"
  echo "Creating Kubernetes Cluster environment ..."
  if [[ "1" == "$KUBERNETES_CLUSTER_INSTALLED" ]]; then
    echo -e "WARNING: Kubernetes cluster applications already installed!!\nPlease run \"--delete\" option first or \"--redeploy\" instead..."
    echo -e "\nExiting ..."
    exit 0
  fi
  if [[ "1" == "$KUBERNETES_STATUS" ]]; then
    echo -e "WARNING: Kubernetes cluster already running!!\nIf it doesn't sound good for you please stop or destroy cluster.\nYou can check cluster status running \"minikube status\""
    echo -e "\nExiting ..."
    exit 0
  fi

  if [[ "--force-rebuild" == "$2" ]]; then
    FORCE_REBUILD="1"
  fi
  if [[ $# -gt 2 ]]; then
    SUFFIX="$(checkSuffix $3)"
  else
    SUFFIX="$(checkSuffix $2)"
  fi
  echo "Using suffix : $(echo "$SUFFIX" | sed 's/^-//g')"

  startMinikubeAndHelm $(pwd)/mnt-point /mnt/storage

  echo "Installing incubator charts repository ...."

  installRepository "incubator" "https://kubernetes-charts-incubator.storage.googleapis.com/"

  echo "Installing continuous charts repository ...."

  installRepository "continuous-delivery" "https://hellgate75.github.io/continuous-delivery-charts/"
  CHART_STATE="$(installChart "local" "jenkins-agent" "jenkins-agent-1" "jenkins-agent-1")"
  EXIT_STATE="$?"
  echo -e "Installing Jenkins Agent 1 : \n$CHART_STATE"
  echo "Response for Jenkins Agent 1 : $EXIT_STATE"
  waitForPod "jenkins-agent-1" "Waiting Jenkins Agent 1 to be up and running ..." 6 50 false 1

  CHART_STATE="$(installChart "local" "jenkins-agent" "jenkins-agent-2" "jenkins-agent-2")"
  EXIT_STATE="$?"
  echo -e "Installing Jenkins Agent 2 : \n$CHART_STATE"
  echo "Response for Jenkins Agent 2 : $EXIT_STATE"
  waitForPod "jenkins-agent-2" "Waiting Jenkins Agent 2 to be up and running ..." 6 50 false 1

  CHART_STATE="$(installChart "local" "nexus3" "nexus3" "nexus3")"
  EXIT_STATE="$?"
  echo -e "Installing Nexus 3 : \n$CHART_STATE"
  echo "Response for Nexus 3 : $EXIT_STATE"
  waitForPod "nexus3" "Waiting Nexus 3 to be up and running ..." 6 50 false 1

  minikube ssh "sudo bash -c \"cd /mnt/storage && ./restore-volume-to.sh samples_nexus3_data nexus3 \""

  CHART_STATE="$(installChart "local" "sonardb" "sonardb" "sonardb")"
  EXIT_STATE="$?"
  echo -e "Installing SonarQube MySQL Database : \n$CHART_STATE"
  echo "Response for SonarQube MySQL Database : $EXIT_STATE"
  waitForPod "nexus3" "Waiting MySQL Database to be up and running ..." 6 50 false 1

  minikube ssh "sudo bash -c \"cd /mnt/storage && ./restore-volume-to.sh samples_sonarqube_db_data sonardb \""

  CHART_STATE="$(installChart "local" "sonar" "sonar" "sonarqube")"
  EXIT_STATE="$?"
  echo -e "Installing SonarQube : \n$CHART_STATE"
  echo "Response for SonarQube : $EXIT_STATE"
  waitForPod "nexus3" "Waiting SonarQube to be up and running ..." 6 100 false 1

  minikube ssh "sudo bash -c \"cd /mnt/storage && ./restore-volume-to.sh samples_sonarqube_data sonarqube \""

  CHART_STATE="$(installChart "local" "jenkins" "jenkins" "jenkins")"
  EXIT_STATE="$?"
  echo -e "Installing Jenkins : \n$CHART_STATE"
  echo "Response for Jenkins : $EXIT_STATE"
  waitForPod "jenkins" "Waiting Jenkins to be up and running ..." 6 100 false 1 "-agent"

  ## advertise about Kubernetes cluster capabilities and dependencies
  echo "$(advertise "$SUFFIX" "LEADER_IP")"
  exit 0


elif [[ "--redeploy" == "$1" ]]; then
  ## Create first time Kubernetes cluster vm nodes
  ## Required :
  ##   (none)
  ## Optional :
  ##   - rebuild parameter
  ##   - force docker image built
  ##   - Docker Machine Suffix name
  echo "$(logo)"
  echo "Environment: $ENVIRONMENT"
  echo "Redeploy CD on Kubernetes Cluster environment ..."
  echo -e "WARNING: Feature not implemented!!\nExiting ..."
  exit 0
  if [[ "0" == "$KUBERNETES_CLUSTER_INSTALLED" ]]; then
    echo -e "WARNING: Kubernetes cluster applications not installed!!\nPlease run \"--create\" option as first..."
    echo -e "\nExiting ..."
    exit 0
  fi
  if [[ "0" == "$KUBERNETES_STATUS" ]]; then
    echo -e "WARNING: Kubernetes cluster not running or failing!!\nIf it doesn't sound good for you please start or destroy cluster.\nYou can check cluster status running \"minikube status\""
    echo -e "\nExiting ..."
    exit 0
  fi
  REBUILD="0"
  COPYYAML="0"
  FORCE_REBUILD="0"
  if [[ "--rebuild" == "$2" ]]; then
    REBUILD="1"
  fi
  if [[ "--force-rebuild" == "$2" ]]; then
    FORCE_REBUILD="1"
  fi
  if [[ "--rebuild" == "$3" ]]; then
    REBUILD="1"
  fi
  if [[ "--force-rebuild" == "$3" ]]; then
    FORCE_REBUILD="1"
  fi
  if [[ "--rebuild" == "$4" ]]; then
    REBUILD="1"
  fi
  if [[ "--force-rebuild" == "$4" ]]; then
    FORCE_REBUILD="1"
  fi
  if [[ $# -gt 4 ]]; then
    SUFFIX="$(checkSuffix $5)"
  elif [[ $# -gt 3 ]]; then
    SUFFIX="$(checkSuffix $4)"
  elif [[ $# -gt 2 ]]; then
    SUFFIX="$(checkSuffix $3)"
  elif [[ $# -gt 1 ]]; then
    SUFFIX="$(checkSuffix $2)"
  else
    SUFFIX="$(checkSuffix $1)"
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


  if  [[ "1" == "$REBUILD" ]]; then
    echo "Rebuild in progress ..."
  fi
  ## redeploy continuous delivery stack on Kubernetes cluster, connecting to leader (manager) node
  echo "Creating cd service stack ..."
else
  echo "$(usage)"
  exit 1
fi
