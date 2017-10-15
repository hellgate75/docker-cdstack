#!/bin/bash
export POD_NAME=$(kubectl get pods --namespace default -l "app=sonar,release=sonarqube" -o jsonpath="{.items[0].metadata.name}")
echo "Visit http://127.0.0.1:9000/sonar to use your application"
kubectl port-forward $POD_NAME 9000:9000
