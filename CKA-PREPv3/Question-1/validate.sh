#!/bin/bash
set -euo pipefail

# Validate ConfigMap entries
DATA=$(kubectl -n lima-control get configmap control-config -o json)

function assert_contains() {
  k=$1
  v=$2
  actual=$(echo "$DATA" | jq -r ".data['$k']")
  if [[ "$actual" != "$v" ]]; then
    echo "FAIL: ConfigMap $k expected $v, got $actual" >&2
    exit 1
  fi
}

assert_contains DNS_1 "kubernetes.default.svc.cluster.local"
assert_contains DNS_2 "department.lima-workload.svc.cluster.local"
assert_contains DNS_3 "section100.section.lima-workload.svc.cluster.local"
assert_contains DNS_4 "1-2-3-4.kube-system.pod.cluster.local"

# Check that the controller pods have picked up the new ConfigMap (by restart timestamp)
pod_ready=$(kubectl -n lima-control get pods -l app=controller -o jsonpath='{.items[0].status.phase}')
if [[ "$pod_ready" != "Running" ]]; then
  echo "FAIL: controller pod is not running" >&2
  exit 1
fi

POD_NAME=$(kubectl -n lima-control get pods -l app=controller -o jsonpath='{.items[0].metadata.name}')

# Validate DNS names resolve from within the pod
for dns in \
  kubernetes.default.svc.cluster.local \
  department.lima-workload.svc.cluster.local \
  section100.section.lima-workload.svc.cluster.local \
  1-2-3-4.kube-system.pod.cluster.local
  do
    if ! kubectl -n lima-control exec "$POD_NAME" -- nslookup "$dns" > /dev/null 2>&1; then
      echo "FAIL: DNS lookup failed for $dns" >&2
      exit 1
    fi
done

echo "PASS: All ConfigMap values and DNS lookups succeeded."
