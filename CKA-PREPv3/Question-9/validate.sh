#!/bin/bash
set -euo pipefail

# 1. Check that manual-schedule pod exists and is Running on controlplane
pod_node=$(kubectl get pod manual-schedule -n default -o=jsonpath='{.spec.nodeName}')
pod_status=$(kubectl get pod manual-schedule -n default -o=jsonpath='{.status.phase}')
if [ "$pod_status" != "Running" ]; then
  echo "manual-schedule pod is not Running."
  exit 1
fi
if [ "$pod_node" != "controlplane" ]; then
  echo "manual-schedule pod is not on controlplane."
  exit 1
fi

# 2. Check that kube-scheduler pod is Running
scheduler_status=$(kubectl get pod -l component=kube-scheduler -n kube-system -o jsonpath='{.items[0].status.phase}')
if [ "$scheduler_status" != "Running" ]; then
  echo "kube-scheduler pod not Running."
  exit 1
fi

# 3. Check that manual-schedule2 pod is Running on node01
m2_node=$(kubectl get pod manual-schedule2 -n default -o=jsonpath='{.spec.nodeName}')
m2_status=$(kubectl get pod manual-schedule2 -n default -o=jsonpath='{.status.phase}')
if [ "$m2_status" != "Running" ]; then
  echo "manual-schedule2 pod is not Running."
  exit 1
fi
if [ "$m2_node" != "node01" ]; then
  echo "manual-schedule2 pod is not on node01."
  exit 1
fi

echo "Validation successful: All checks passed."
