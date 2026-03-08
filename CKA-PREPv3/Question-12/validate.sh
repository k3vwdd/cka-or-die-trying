#!/bin/bash
set -euo pipefail

# Verify pod exists and is running
status=$(kubectl get pod pod1 -n default -o jsonpath='{.status.phase}')
if [[ "$status" != "Running" && "$status" != "Pending" ]]; then
  echo "Pod pod1 not found or not in Running/Pending status"
  exit 1
fi

# Check node where pod is scheduled
node=$(kubectl get pod pod1 -n default -o jsonpath='{.spec.nodeName}')

# Check if node is a control-plane node by role label (actual label is not required on the node per question)
# Instead, the pod spec should contain nodeSelector for node-role.kubernetes.io/control-plane: ""
podSelector=$(kubectl get pod pod1 -n default -o jsonpath='{.spec.nodeSelector.node-role\.kubernetes\.io\/control-plane}')
if [[ "$podSelector" != "" ]]; then
  echo "Pod has correct nodeSelector for controlplane nodes."
else
  echo "Pod does NOT have correct nodeSelector for controlplane nodes."
  exit 1
fi

# Check for toleration
timeout 10 kubectl get pod pod1 -n default
hasToleration=$(kubectl get pod pod1 -n default -o json | grep 'node-role.kubernetes.io/control-plane')
if [[ -n "$hasToleration" ]]; then
  echo "Pod has correct toleration for control-plane taint."
else
  echo "Pod does NOT have correct toleration for control-plane taint."
  exit 1
fi

echo "Validation PASSED."
