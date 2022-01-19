#/bin/bash

kubectl create ns nginx
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install nginx-operator ingress-nginx/ingress-nginx -n nginx
