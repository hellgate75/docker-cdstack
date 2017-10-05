#!/bin/environment bash
export SWARM_LOCAL_LEADER_MEMORY="750"
export SWARM_LOCAL_LEADER_DISK="50000"
export SWARM_LOCAL_LEADER_CUPS="1"
export SWARM_ADVANCED_JENKINS_AGENTS_MEMORY="750"
export SWARM_ADVANCED_JENKINS_AGENTS_DISK="30000"
export SWARM_ADVANCED_JENKINS_AGENTS_CUPS="1"
export SWARM_LOCAL_JENKINS_MEMORYS="750"
export SWARM_LOCAL_JENKINS_DISK="30000"
export SWARM_LOCAL_JENKINS_CUPS="1"
export SWARM_LOCAL_NEXUS_MEMORY="750"
export SWARM_LOCAL_NEXUS_DISK="30000"
export SWARM_LOCAL_NEXUS_CUPS="1"
export SWARM_LOCAL_SONAR_MEMORY="1920"
export SWARM_LOCAL_SONAR_DISK="40000"
export SWARM_LOCAL_SONAR_CUPS="2"
##########################################################################
## Define project security constraints                                  ##
##########################################################################
export SWARM_LOCAL_PORTAINER_ADMIN_PASSWORD="admin123"
export SWARM_LOCAL_PORTAINER_STD_USER_NAME="user"
export SWARM_LOCAL_PORTAINER_STD_USER_PWD="user123"
##########################################################################
## Define project name and prject prefix                                ##
##########################################################################
export SWARM_PROJECT_NAME="C.D. Pipeline by Jenkins Agents"
export SWARM_PROJECT_PREFIX="delivery-pipeline"
export SWARM_REGISTRY_USER="admin"
export SWARM_REGISTRY_PASSWORD="admin"
export SWARM_APP_COMPOSE_SUFFIX="-minimal"
