#!/bin/bash
if [[ $# -lt 1 ]]; then
  echo "Error: insufficient parameters"
  echo "Syntax: restore-volume.sh volume_name"
  exit 1
fi

volume_name="$(echo "$1"|sed s/_/-/g)"

if ! [[ -z "$(docker volume ls| grep $volume_name)" ]]; then
  docker volume rm "$volume_name"
fi
docker volume create --name "$volume_name"

echo "Restore of volume $volume_name in progress ..."
docker run --rm -it -v "$volume_name:/volume" -v "$(pwd)/archives:/backup" ubuntu:16.10 \
    bash -c "rm -Rf /volume/*; tar -xzf /backup/$1.tgz -C /volume"
if [[ "0" == "$?" ]]; then
  echo "Restore of volume $volume_name succeeded : restore from archive : $(pwd)/archives/$1.tgz"
else
  echo "Restore of volume $volume_name failed!!"
fi
