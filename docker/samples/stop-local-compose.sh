#!/bin/bash
if [[ "--volumes" == "$1" ]]; then
  docker-compose -f docker-compose-local.yml down -v
else
  docker-compose -f docker-compose-local.yml down
fi
