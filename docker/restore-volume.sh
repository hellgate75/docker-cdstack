#!/bin/bash
if [[ $# -lt 1 ]]; then
  echo "Error: insufficient parameters"
  echo "Syntax: restore-volume.sh volume_name"
  exit 1
fi

if [[ -z "$(docker volume ls| grep $1)" ]]; then
  echo "Volume $1 doeasn't exists creating a new one ..."
  docker volume create "$1"
fi

echo "Restore of volume $1 in progress ..."
docker run --rm -it -v "$1:/volume" -v "$(pwd)/archives:/backup" ubuntu:16.10 \
    bash -c "rm -Rf /volume/*; tar -xzf /backup/$1.tgz -C /volume"
if [[ "0" == "$?" ]]; then
  echo "Restore of volume $1 succeeded : restore from archive : $(pwd)/archives/$1.tgz"
else
  echo "Restore of volume $1 failed!!"
fi
