#!/bin/bash
set -euo pipefail

PHASE=$(kubectl get pod cp-only -n default -o jsonpath='{.status.phase}' 2>/dev/null || true)
[ "$PHASE" = "Running" ] || { echo "FAIL: cp-only not running"; exit 1; }

NODE=$(kubectl get pod cp-only -n default -o jsonpath='{.spec.nodeName}')
kubectl get node "$NODE" -o jsonpath='{.metadata.labels.node-role\.kubernetes\.io/control-plane}' >/dev/null 2>&1 || {
  echo "FAIL: pod not on controlplane"
  exit 1
}

echo "PASS: Question 14"
