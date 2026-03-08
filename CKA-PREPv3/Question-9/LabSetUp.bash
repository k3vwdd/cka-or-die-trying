#!/bin/bash
set -e

# Move kube-scheduler.yaml back to ensure scheduler is running (cleanup from previous runs)
if [ -f /etc/kubernetes/kube-scheduler.yaml ]; then
  mv /etc/kubernetes/kube-scheduler.yaml /etc/kubernetes/manifests/
  sleep 5
fi

# Delete test pods if they exist
kubectl delete pod manual-schedule manual-schedule2 -n default --ignore-not-found

# Wait for kube-scheduler to be Ready
kubectl wait --for=condition=Ready pod -l component=kube-scheduler -n kube-system --timeout=60s || true

# Ensure image is pre-pulled for httpd:2-alpine (performance)
kubectl get nodes -o name | xargs -I{} kubectl debug {} --image=httpd:2-alpine -- bash -c 'exit 0' || true
