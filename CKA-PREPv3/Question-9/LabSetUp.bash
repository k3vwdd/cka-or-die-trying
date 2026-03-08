#!/bin/bash
set -e

# Cleanup from possible previous runs
kubectl delete pod manual-schedule --ignore-not-found=true >/dev/null 2>&1 || true
kubectl delete pod manual-schedule2 --ignore-not-found=true >/dev/null 2>&1 || true
rm -f /tmp/manual-schedule.yaml

# Best-effort restore of kube-scheduler manifest to its expected location if needed
if [ -f /etc/kubernetes/kube-scheduler.yaml ] && [ ! -f /etc/kubernetes/manifests/kube-scheduler.yaml ]; then
  mv /etc/kubernetes/kube-scheduler.yaml /etc/kubernetes/manifests/
fi

# Wait briefly for scheduler static pod to come back if manifest exists
if [ -f /etc/kubernetes/manifests/kube-scheduler.yaml ]; then
  kubectl -n kube-system wait --for=condition=Ready pod -l component=kube-scheduler --timeout=120s >/dev/null 2>&1 || true
fi
