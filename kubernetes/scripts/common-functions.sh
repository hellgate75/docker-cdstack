#!/bin/bash


MINIKUBE_VERSION="${MINIKUBE_VERSION:-"0.22.3"}"
REMOTE_VOLUME_FOLDER_URL="${REMOTE_VOLUME_FOLDER_URL:-"https://s3-eu-west-1.amazonaws.com/ftorelli-docker-configuration/continuous-delivery/volumes"}"

##########################################################################
## Define project name and prject prefix                                ##
##########################################################################
PROJECT_NAME="${KUBERNETES_PROJECT_NAME:-"Delivery Sample"}"
PROJECT_PREFIX="${KUBERNETES_PROJECT_PREFIX:-"sample"}"

##########################################################################
## Print commmand usage                                                 ##
## Parameters :                                                         ##
##   (none)                                                             ##
## Returns:                                                             ##
##   - command usage text                                               ##
##########################################################################
function logo() {
  echo "###################################################################################################################"
  echo "   $PROJECT_NAME Project - Continuous Delivery Platform"
  echo "###################################################################################################################"
  echo " "
  echo " "
  echo "      G O O G L E"
  echo ""
  echo "        ###   ###  ##   ##  #######    #######  #######    ###   ###  #######  #######    #######   #####  "
  echo "        # #   # #  ##   ##  #  ### #   # #####  #  ### #   #  #  # #  # #####  ### ###    # #####  # ### # "
  echo "        # #   # #  ##   ##  # #   # #  # #      # #   # #  #   # # #  # #        # #      # #      # # ### "
  echo "        # # #  #   ##   ##  # #### #   # #      # #### #   # #  ## #  # #        # #      # #       # #    "
  echo "        # # # #    ##   ##  # ### #    # ####   # ### #    # ##  # #  # ####     # #      # ####     # #   "
  echo "        # # #  #   ##   ##  # #  # #   # ####   # #  # #   # # #   #  # ####     # #      # ####       # # "
  echo "        # #   # #  ##   ##  # #  # #   # #      # #   # #  # #  #  #  # #        # #      # #      ###  # #"
  echo "        # #   # #  #######  # ### #    # #      # #   # #  # #   # #  # #        # #      # #      # ###  #"
  echo "        ###   ###   #####   #######    #######  ###   ###  ###   ###  #######    ###      #######   ###### "
  echo " "
  echo "      T O O L S E T"
  echo " "
  echo " "
  echo "###################################################################################################################"
  echo "##          K U B E R N E T E S   C L U S T E R  N O D E S   M A N A G E M E N T   S W I S S - K N I F E         ##"
  echo "###################################################################################################################"
  echo " "
  echo "###################################################################################################################"
  echo "   Project Prefix: $PROJECT_PREFIX     Minikube version: $MINIKUBE_VERSION"
  echo "###################################################################################################################"
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
  echo "        manage-k8s-env.sh environment --create|--destroy|--start|--stop|--redeploy [environment] [suffix]"
  echo "        [environment]      Type of environment to use [local, aws or azure]"
  echo "        --status     Print status for nodes, based on public IPs/URLs"
  echo "        --create     Create or update platform in case of stop of nodes"
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
  echo " "
  echo " "
  echo "Containers can be not not ready. It could take up to 300 seconds, please check following service status:"
  echo ""
  JENKINS_IP="$(getPublicURL "jenkins-public")"
  echo "Jenkins status : $(getUrlStatus "$JENKINS_IP")"
  echo "Jenkins console at: $JENKINS_IP"
  echo ""
  NEXUS3_IP="$(getPublicURL "nexus3-public")"
  echo "Nexus 3 OSS status : $(getUrlStatus "$NEXUS3_IP")"
  echo "Nexus 3 OSS console at: $NEXUS3_IP"
  echo ""
  DOCKER_STAGING_IP="$(getPublicURL "nexus3-docker-staging")"
  echo "Nexus 3 Docker Staging Registry status : $(getUrlStatus "$DOCKER_STAGING_IP")"
  echo "Nexus 3 Docker Staging Registry at: $(echo $DOCKER_STAGING_IP|awk 'BEGIN {FS=OFS="/"}{print $NF}')"
  echo ""
  DOCKER_PROD_IP="$(getPublicURL "nexus3-docker-prod")"
  echo "Nexus 3 Docker Production Registry status : $(getUrlStatus "$DOCKER_PROD_IP")"
  echo "Nexus 3 Docker Production Registry at: $(echo $DOCKER_PROD_IP||awk 'BEGIN {FS=OFS="/"}{print $NF}')"
  echo ""
  SONARQUBE_IP="$(getPublicURL "sonarqube-public")"
  echo "SonarQube status : $(getUrlStatus "$SONARQUBE_IP/sonar")"
  echo "SonarQube console at: $SONARQUBE_IP/sonar"
  echo " "
  echo " "
}

function isVirtualBoxInstalled() {
  if [[ -z "$(which vboxmanage)" ]]; then
    echo "0"
  else
    echo "1"
  fi
}

function isLinuxOS() {
  if [[ -z "$(uname -a|grep Linux)" ]]; then
    echo "0"
  else
    echo "1"
  fi
}

##########################################################################
## Start Minikube helm environment                                      ##
## Parameters :                                                         ##
##   (none)                                                             ##
## Options :                                                            ##
##   host folder - Folder to be shared with minikube                    ##
##   guest folder - Folder shared on minikube                           ##
## Returns:                                                             ##
##   (none)                                                             ##
##########################################################################
function startMinikubeAndHelm() {
  if ! [[ -z "$(which minikube)" ]]; then
    echo "Starting minikube ..."
    minikube start --disk-size=60g --memory=6144 --cpus 5 --vm-driver virtualbox
    if [[ $# -gt 1 ]]; then
      sleep 5
      echo "Mounting folder $1 on minukube at $2 ..."
      minikube stop
      sleep 5
      vboxmanage sharedfolder add minikube --name "$2" --hostpath "$1" --automount
      sleep 5
      minikube start --disk-size=60g --memory=6144 --cpus 5
    fi
    eval $(minikube docker-env)
  else
    echo "Minikube not installed"
  fi
  if ! [[ -z "$(which helm)" ]]; then
    echo "Starting helm ..."
    # if ! [[ -e ~/.helm ]]; then
    #   helm init
    #   echo "Helm started waiting deploy of apps ..."
    #   sleep 60
    # else
      helm init
      waitForPod "tiller" "Helm started, waiting for deploy of tiller pod" 6 15 true 1
      helm init --upgrade
      waitForPod "tiller" "Helm started, waiting for upgrade of tiller pod" 6 15 true 1

     # fi
  else
    echo "Helm not installed"
  fi
  waitforAllPodsToBeUp
}

function checkAndInstallS3Archive() {
    if ! [[ -e "$(pwd)/mnt-point/archives/$1.tgz"  ]]; then
      echo "Downloading $2 volume backup from S3 ..."
      mkdir -p $(pwd)/mnt-point/archives
      curl -L "$REMOTE_VOLUME_FOLDER_URL/$1.tgz" -o "$(pwd)/mnt-point/archives/$1.tgz"
    fi
}

function getUrlStatus() {
  curl -L --silent "$1" &> /dev/null
  if [[ "$?" == "0" ]]; then
    echo "Running"
  else
    echo "Stopped/Starting"
  fi
}

function getAllPodStates() {
  echo "$(kubectl get pods  --all-namespaces=true | grep -v READY | awk 'BEGIN {FS=OFS=" "}{print $3"/"$4}'|awk 'BEGIN {FS=OFS="/"}{print ( $1==$2 && $3=="Running" )}')"
}

MOVE_UP=$(printf "\033[1A")
MOVE_DOWN=$(printf "\033[1B")
MOVE_RIGHT=$(printf "\033[1C")

function waitforAllPodsToBeUp() {
  text="Waiting for all Pods to be Up, Running and Ready "
  if [[ -z "$1" ]]; then
    echo -ne "$text"
  fi
  PARAM="$1"
  TEXTLEN=$(expr length "$text")
  COUNTER=${PARAM:-$TEXTLEN}
  POD_STATES="$(getAllPodStates)"
  ERRORS=0
  while read line;
  do
    if [[ "$line" == "0" ]]; then
      ERRORS=1
      break
    fi
  done <<< "$POD_STATES"
  if [[ "1" == "$ERRORS" ]]; then
    echo -ne "."
    sleep 10
    COUNTER=$[COUNTER + 1]
    waitforAllPodsToBeUp $COUNTER
  else
  echo -e "\n"
  fi
}

function waitForAppToBeUp() {
  echo -ne "Waiting for $3 application to be available"
  SONARQUBE_IP="$(getPublicURL "$1")"
  while [[ "Running" != "$(getUrlStatus "$SONARQUBE_IP$2")" ]];
  do
    echo -ne "."
    sleep 10
  done
  echo -e "\n"
}

function installRepository() {
  helm repo add "$1" "$2"
  return $?
}


function installChart() {
  if [[ $# -lt 4 ]]; then
    echo "installChart <environment> <chart-name> <config-file> <container-name>"
    return 1
  fi
  helm delete --purge "$4"
  helm install continuous-delivery/$2 --namespace default --name "$4" -f $(pwd)/kubernetes-$1/charts/$3.yaml "${@:5}"
  return $?
}

function waitForPod() {
  if [[ $# -lt 5 ]]; then
    return 1
  fi
  PARAM="$2 "
  # TEXTLEN=$(expr length "$PARAM")
  echo -ne "$PARAM"
  cycles=1
  if [[ -z "$7" ]]; then
    while [[ -z "$(kubectl get pods --all-namespaces=$5|grep $1|grep -i running|grep "$6/$6")" ]];
    do
      echo -ne "."
      sleep $3
      cycles=$(( cycles+1 ))
      if [[ $cycles -gt $4 ]]; then
        echo -e "\n"
        return 1
      fi
    done
  else
    while [[ -z "$(kubectl get pods --all-namespaces=$5|grep $1|grep -i running|grep "$6/$6"|grep -v "$7")" ]];
    do
      echo -ne "."
      sleep $3
      cycles=$[cycles+1]
      if [[ $cycles -gt $4 ]]; then
        echo -e "\n"
        return 1
      fi
    done
  fi
  echo -e "\n"
  return 0
}

function startDashboard() {
    minikube dashboard
    kubectl cluster-info
}

function createPublicURL() {
  kubectl expose service "$1" --port="$2" --type=NodePort --name="$3"
  return "$?"
}

function getPublicURL() {
    minikube service "$1" --url
}

function kubernetesStatus() {
  STATUS="$(minikube status)"
  minikube_on="0"
  cluster_on="0"
  kubectl_ok="0"
  while read line;
  do
    minikube=0
    cluster=0
    kubectl=0
    for token in ${line//:/ };
    do
      if [[ $minikube -gt 0 ]]; then
        if ! [[ -z "$(echo "$token"|grep -i running)" ]]; then
          minikube_on="1"
        fi
        minikube=0
      elif [[ $cluster -gt 0 ]]; then
        if ! [[ -z "$(echo "$token"|grep -i running)" ]]; then
          cluster_on="1"
        fi
        cluster=0
      elif [[ $kubectl -gt 0 ]]; then
        if ! [[ -z "$(echo "$token"|grep -i correctly)" ]]; then
          kubectl_ok="1"
        fi
        kubectl=0
      else
        if [[ "minikube" == "$token" ]]; then
          minikube=1
        elif [[ "cluster" == "$token" ]]; then
          cluster=1
        elif [[ "kubectl" == "$token" ]]; then
          kubectl=1
        fi
      fi
    done
  done <<< "$STATUS"
  echo "$minikube_on $cluster_on $kubectl_ok"
}

function initialRefresh() {
  eval "$(minikube docker-env)"
  if ! [[ -z "$(which helm)" ]]; then
    echo "Starting helm ..."
    if ! [[ -e ~/.help ]]; then
      helm init
    fi
  else
    echo "Helm not installed"
  fi
}

function isKubernetOperable() {
  if [[ -z "$(which minikube)" ]]; then
    echo "0"
  elif [[ -z "$(which kubectl)" ]]; then
    echo "0"
  elif [[ -z "$(which helm)" ]]; then
    echo "0"
  fi
  echo "1"
}

##########################################################################
## Install Minikube if not present                                      ##
## Parameters :                                                         ##
##   (none)                                                             ##
## Returns:                                                             ##
##   (none)                                                             ##
##########################################################################
function installMinikube() {
  if [[ -z "$(which minikube)" ]]; then
    echo "Installing minikube ..."
    curl -Lo minikube https://storage.googleapis.com/minikube/releases/v$MINIKUBE_VERSION/minikube-linux-amd64 \
    && chmod +x minikube \
    && sudo mv minikube /usr/local/bin/
    if ! [[ -z "$(which minikube)" ]]; then
      echo "Minikube installed!!"
      echo "MINIKUBE_VERSION=\"$MINIKUBE_VERSION\"" >> ~/.bashrc
    else
      echo "Minikube NOT installed!!"
    fi
  else
    echo "Minikube already installed!!"
  fi
}

##########################################################################
## Install Kubectl if not present                                       ##
## Parameters :                                                         ##
##   (none)                                                             ##
## Returns:                                                             ##
##   (none)                                                             ##
##########################################################################
function installKubectl() {
  if [[ -z "$(which kubectl)" ]]; then
    echo "Installing kubectl ..."
    curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
    && chmod +x kubectl \
    && sudo mv kubectl /usr/local/bin/kubectl
    if ! [[ -z "$(which kubectl)" ]]; then
      echo "Kubectl installed!!"
      echo "source <(kubectl completion bash)" >> ~/.bashrc
    else
      echo "Kubectl NOT installed!!"
    fi
  else
    echo "Kubectl already installed!!"
  fi
}

##########################################################################
## Install Helm if not present                                          ##
## Parameters :                                                         ##
##   (none)                                                             ##
## Returns:                                                             ##
##   (none)                                                             ##
##########################################################################
function installHelm() {
  if [[ -z "$(which helm)" ]]; then
    echo "Installing helm ..."
    curl -Lo get_helm.sh https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get \
    && chmod 777 get_helm.sh \
    && sudo ./get_helm.sh \
    && rm -f ./get_helm.sh
    if ! [[ -z "$(which helm)" ]]; then
      echo "Helm installed!!"
      echo "Now installing useful Helm plugins!!"
      helm plugin install https://github.com/adamreese/helm-tiller
      helm plugin install https://github.com/technosophos/helm-template
      helm plugin install https://github.com/databus23/helm-diff
      helm plugin install https://github.com/skuid/helm-value-store
      helm plugin install https://github.com/adamreese/helm-env
      helm plugin install https://github.com/adamreese/helm-nuke
      helm plugin install https://github.com/mstrzele/helm-edit
      echo "Here list of installed Helm plugins:"
      helm plugin list
    else
      echo "Helm NOT installed!!"
    fi
  else
    echo "Helm already installed!!"
  fi
}

##########################################################################
## Install Kubernetes tools if not present                              ##
## Parameters :                                                         ##
##   (none)                                                             ##
## Returns:                                                             ##
##   (none)                                                             ##
##########################################################################
function installKubetools() {
  if ! [[ -e /etc/apt/sources.list.d/kubernetes.list ]]; then
    echo "Installing kubelet kubeadm ..."
    sudo bash -c "apt-get update \
    && apt-get install -y apt-transport-https \
    && curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
    && echo \"deb http://apt.kubernetes.io/ kubernetes-xenial main\" > /etc/apt/sources.list.d/kubernetes.list \
    && apt-get update \
    && apt-get install -y kubelet kubeadm"
  else
    echo "Kubelet Kubeadm already installed!!"
    # sudo apt-get update \
    # && sudo apt-get -y upgrade
  fi
}

##########################################################################
## Clean Previous Miikube, Helm, Kubernetes Installations               ##
## Parameters :                                                         ##
##   (none)                                                             ##
## Returns:                                                             ##
##   output                                                             ##
##########################################################################

function cleanPreviousInstallations() {
  echo "Cleaning minikube installation ..."
  if ! [[ -z "$(which minikube)" ]]; then
    sudo rm -f $(which minikube)
    rm -f ~/.minikube
  fi
  echo "Cleaning helm installation ..."
  if ! [[ -z "$(which helm)" ]]; then
    sudo rm -f $(which helm)
    rm -f ~/.helm
  fi
  echo "Cleaning kubectl installation ..."
  if ! [[ -z "$(which kubectl)" ]]; then
    sudo rm -f $(which kubectl)
  fi
  if [[ -e /etc/apt/sources.list.d/kubernetes.list ]]; then
    echo "Cleaning kubelet kubeadm ..."
    sudo bash -c "apt-get -y remove kubelet kubeadm"
    sudo rm -rf /etc/apt/sources.list.d/kubernetes.list
  fi
}
