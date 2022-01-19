# /bin/bash

set -e

kubectl create namespace weblogic
kubectl create serviceaccount weblogic -n weblogic

git clone --branch v3.3.7 https://github.com/oracle/weblogic-kubernetes-operator

helm install weblogic-operator weblogic-kubernetes-operator/kubernetes/charts/weblogic-operator \
  --namespace weblogic \
  --set image=ghcr.io/oracle/weblogic-kubernetes-operator:3.3.7 \
  --set serviceAccount=weblogic \
  --set "enableClusterRoleBinding=true" \
  --set "domainNamespaceSelectionStrategy=LabelSelector" \
  --set "domainNamespaceLabelSelector=weblogic-operator\=enabled" \
  --wait
