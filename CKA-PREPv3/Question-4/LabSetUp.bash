#!/bin/bash
set -e

# Ensure the default namespace exists (should be present by default)
# Remove any leftover resources from previous runs
kubectl delete pod ready-if-service-ready am-i-ready --ignore-not-found -n default

# Remove the manifest if present	rm -f /tmp/ready-if-service-ready.yaml

# Ensure that any existing service is present (the question assumes 'service-am-i-ready' already exists)
# If not, create a dummy service (for the lab setup only - this Service will not have endpoints yet)
if ! kubectl get svc service-am-i-ready -n default &>/dev/null; then
  kubectl expose deployment nginx \ 
    --name=service-am-i-ready \ 
    --port=80 \ 
    -n default --dry-run=client -o yaml |
    kubectl apply -f -
fi

# If 'nginx' deployment was created solely for the placeholder Service above, delete deployment (not asked by Question)
kubectl delete deployment nginx --ignore-not-found -n default
