#!/bin/bash
export POD_NAME=$(kubectl get pods --namespace default -l "app=nexus3,release=nexus3" -o jsonpath="{.items[0].metadata.name}")
echo "Visit http://127.0.0.1:8081 to use your application"
kubectl port-forward $POD_NAME 8081:8081
