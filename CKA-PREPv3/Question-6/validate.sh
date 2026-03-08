#!/bin/bash
set -euo pipefail
# Node Ready check
node=$(kubectl get node -l node-role.kubernetes.io/control-plane -o jsonpath='{.items[0].metadata.name}')
[ -n "$node" ] || node=controlplane
node_ready=$(kubectl get nodes "$node" --no-headers | grep -q ' Ready ' && echo 1 || echo 0)
if [ "$node_ready" -eq 0 ]; then
  echo "FAIL: Node $node is not Ready"
  exit 1
fi
# Pod existence and status check
if ! kubectl get pod success -n default -o json | jq -e '.status.phase == "Running"'; then
  echo "FAIL: Pod 'success' is not Running in namespace 'default'"
  exit 1
fi
echo "PASS: Node $node is Ready and Pod 'success' is Running in namespace 'default'!"
