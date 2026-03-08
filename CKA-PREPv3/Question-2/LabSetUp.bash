#!/bin/bash
set -e

# Clean up any old static pod or service artifacts
sudo rm -f /etc/kubernetes/manifests/my-static-pod.yaml
kubectl delete svc static-pod-service --ignore-not-found=true -n default
kubectl delete pod my-static-pod --ignore-not-found=true -n default || true

# Wait for any previous static pod to terminate
sleep 5
