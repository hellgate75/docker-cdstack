#!/bin/bash
if [[ $# -lt 2 ]]; then
  echo "Error: insufficient parameters"
  echo "Syntax: restore-volume-to.sh volume_name container_release"
  exit 1
fi

if ! [[ -e $(pwd)/archives/$1.tgz ]]; then
  echo "Error: Tar Gzipped archive $1.tgz not found ..."
  exit 1
fi


volume_name="$(echo "$1"|sed s/_/-/g)"

folder="$($(pwd)/find-k8s-volume-folder.sh $volume_name)"
container="$($(pwd)/find-k8s-pod-container.sh $2)"

if [[ -z "$folder" ]]; then
  echo "Error: Folder for volume $volume_name not found ..."
  exit 1
fi

if [[ -z "$container" ]]; then
  echo "Error: Pod container for app $2 not found ..."
  exit 1
fi

echo "Restore volume to folder $folder in container $2 in progress ..."
sudo cp $(pwd)/archives/$1.tgz $folder/$1.tar.gz
sudo gunzip $folder/$1.tar.gz
sudo tar -C $folder -xf $folder/$1.tar
sudo rm -f $folder/$1.tar
if [[ "0" == "$?" ]]; then
  echo "Restore of volume to container $2 succeeded : restore from archive : $(pwd)/archives/$1.tgz"
  echo "Restarting container : $container"
  docker restart $container
  status="running"
  if [[ -z "$(docker ps | grep  $container | grep Up)" ]]; then
    status="stopped"
  fi
  echo "container : $container status: $status"
else
  echo "Error: Restore of volume to container $2 failed!!"
  exit 1
fi
