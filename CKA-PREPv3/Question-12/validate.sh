#!/bin/bash
set -euo pipefail

fail() {
  echo "FAIL: $1"
  exit 1
}

pass() {
  echo "PASS"
  exit 0
}

# Check Pod exists in default namespace
kubectl get pod pod1 -n default >/dev/null 2>&1 || fail "Pod pod1 does not exist in namespace default"

# Check container image
image=$(kubectl get pod pod1 -n default -o jsonpath='{.spec.containers[0].image}')
[ "$image" = "httpd:2-alpine" ] || fail "Pod image is '$image', expected 'httpd:2-alpine'"

# Check container name
container_name=$(kubectl get pod pod1 -n default -o jsonpath='{.spec.containers[0].name}')
[ "$container_name" = "pod1-container" ] || fail "Container name is '$container_name', expected 'pod1-container'"

# Check nodeSelector for control-plane node label
node_selector_value=$(kubectl get pod pod1 -n default -o jsonpath='{.spec.nodeSelector.node-role\.kubernetes\.io/control-plane}')
[ "$node_selector_value" = "" ] || fail "Pod nodeSelector for node-role.kubernetes.io/control-plane is missing or incorrect"

# Check toleration for control-plane taint with NoSchedule effect
has_toleration=$(kubectl get pod pod1 -n default -o json | jq -r '
  any(.spec.tolerations[]?; .key == "node-role.kubernetes.io/control-plane" and .effect == "NoSchedule")
')
[ "$has_toleration" = "true" ] || fail "Required toleration for node-role.kubernetes.io/control-plane with effect NoSchedule is missing"

# Check Pod is scheduled
node_name=$(kubectl get pod pod1 -n default -o jsonpath='{.spec.nodeName}')
[ -n "$node_name" ] || fail "Pod pod1 is not scheduled to any node"

# Check scheduled node has control-plane label
node_has_label=$(kubectl get node "$node_name" -o jsonpath='{.metadata.labels.node-role\.kubernetes\.io/control-plane}')
[ "$node_has_label" = "" ] || fail "Pod is not scheduled on a controlplane node"

# Check Pod phase / readiness
phase=$(kubectl get pod pod1 -n default -o jsonpath='{.status.phase}')
[ "$phase" = "Running" ] || fail "Pod phase is '$phase', expected 'Running'"

ready=$(kubectl get pod pod1 -n default -o jsonpath='{.status.containerStatuses[0].ready}')
[ "$ready" = "true" ] || fail "Pod container is not Ready"

pass
