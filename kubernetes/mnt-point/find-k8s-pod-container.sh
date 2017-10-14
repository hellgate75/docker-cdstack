#!/bin/bash
if [[ $# -lt 1 ]]; then
  exit 1
fi
search_text="docker"
if ! [[ -z "$2" ]]; then
  search_text="$2"
fi
docker ps | grep $1|grep $search_text|awk 'BEGIN {FS=OFS=" "}{print $NF}'
