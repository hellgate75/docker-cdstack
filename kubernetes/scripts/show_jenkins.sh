#!/bin/bash
export POD_NAME=$(kubectl get pods --namespace default -l "app=jenkins,release=jenkins" -o jsonpath="{.items[0].metadata.name}")
echo "Visit http://127.0.0.1:8080 to use your application"
kubectl port-forward $POD_NAME 8080:8080
