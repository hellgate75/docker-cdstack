#!/bin/bash
if [[ $# -lt 1 ]]; then
  echo "Error: insufficient parameters"
  echo "Syntax: backup-volume.sh volume_name"
  exit 1
fi
echo "Back up for volume $1 in progress ..."
docker run --rm -it -v "$1:/volume" -v "$(pwd)/archives:/backup" ubuntu:16.10 \
    bash -c "tar -czf /backup/$1.tgz -C /volume ./"
if [[ "0" == "$?" ]]; then
  echo "Back up for volume $1 succeeded : archive available at : $(pwd)/archives/$1.tgz"
else
  echo "Back up for volume $1 failed!!"
fi
