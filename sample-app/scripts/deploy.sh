#!/bin/bash

set -e

SCRIPTS_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
NAMESPACE=sample-deployment-$RANDOM

cd "$SCRIPTS_DIR/.."

echo "Cleaning up previous resources"
./scripts/cleanup-domain.sh -d sample-domain

kubectl delete ns -l ephemeral-deployment=true

echo "Creating a new deployment namespace (just for convinience)"
kubectl create namespace $NAMESPACE
kubectl label ns $NAMESPACE weblogic-operator=enabled ephemeral-deployment=true

echo "Creating weblogic secrets"
kubectl -n $NAMESPACE apply -f deployment/manifests/secrets.yaml

echo "Deploying weblogic domain"
kubectl -n $NAMESPACE apply -f deployment/manifests/domain.yaml

echo "Deploying ingress"
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: sample-domain-ingress
  namespace: $NAMESPACE
  labels: 
    weblogic.domainUID: sample-domain
  annotations:
    # use the shared ingress-nginx
    kubernetes.io/ingress.class: "nginx"
    nginx.ingress.kubernetes.io/rewrite-target: /\$1
spec:
  rules:
  - host:
    http:
      paths:
      - path: /$NAMESPACE(.+)
        pathType: ImplementationSpecific
        backend:
          service:
            name: sample-domain-cluster-cluster-1
            port:
              number: 8001
EOF

timeout --foreground 300s ./scripts/healthcheck.sh http://localhost/$NAMESPACE/sample-app-0.0.1-SNAPSHOT/actuator/health
