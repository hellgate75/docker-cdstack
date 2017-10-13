#!/bin/bash
if [[ "$#" -lt 3 ]]; then
  echo "install-chart.sh <chart-name> <config-file> <container-name>"
  exit 1
fi
helm delete --purge "$3"
helm install continuous-delivery/$1 --namespace default --name "$3" -f ./charts/$2.yaml
