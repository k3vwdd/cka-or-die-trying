#!/bin/bash
set -euo pipefail

fail() {
  echo "FAIL: $1"
  exit 1
}

pass() {
  echo "PASS: $1"
}

# Validate first pod exists in default namespace
kubectl get pod ready-if-service-ready -n default >/dev/null 2>&1 || fail "Pod ready-if-service-ready not found in namespace default"
pass "Pod ready-if-service-ready exists"

# Validate first pod image
img1=$(kubectl get pod ready-if-service-ready -n default -o jsonpath='{.spec.containers[0].image}')
[ "$img1" = "nginx:1-alpine" ] || fail "Pod ready-if-service-ready image is '$img1', expected nginx:1-alpine"
pass "Pod ready-if-service-ready uses image nginx:1-alpine"

# Validate livenessProbe exec true
live_cmd=$(kubectl get pod ready-if-service-ready -n default -o jsonpath='{.spec.containers[0].livenessProbe.exec.command[*]}')
[ "$live_cmd" = "true" ] || fail "Liveness probe command is '$live_cmd', expected 'true'"
pass "Liveness probe executes command true"

# Validate readinessProbe exec command contains service URL
ready_cmd=$(kubectl get pod ready-if-service-ready -n default -o jsonpath='{.spec.containers[0].readinessProbe.exec.command[*]}')
echo "$ready_cmd" | grep -F "wget -T2 -O- http://service-am-i-ready:80" >/dev/null || fail "Readiness probe command does not check http://service-am-i-ready:80"
pass "Readiness probe checks reachability of service-am-i-ready:80"

# Validate second pod exists
kubectl get pod am-i-ready -n default >/dev/null 2>&1 || fail "Pod am-i-ready not found in namespace default"
pass "Pod am-i-ready exists"

# Validate second pod image
img2=$(kubectl get pod am-i-ready -n default -o jsonpath='{.spec.containers[0].image}')
[ "$img2" = "nginx:1-alpine" ] || fail "Pod am-i-ready image is '$img2', expected nginx:1-alpine"
pass "Pod am-i-ready uses image nginx:1-alpine"

# Validate second pod label
label_val=$(kubectl get pod am-i-ready -n default -o jsonpath='{.metadata.labels.id}')
[ "$label_val" = "cross-server-ready" ] || fail "Pod am-i-ready label id is '$label_val', expected cross-server-ready"
pass "Pod am-i-ready has label id=cross-server-ready"

# Validate service exists and selector matches second pod label
kubectl get service service-am-i-ready -n default >/dev/null 2>&1 || fail "Service service-am-i-ready not found in namespace default"
selector_val=$(kubectl get service service-am-i-ready -n default -o jsonpath='{.spec.selector.id}')
[ "$selector_val" = "cross-server-ready" ] || fail "Service selector id is '$selector_val', expected cross-server-ready"
pass "Service service-am-i-ready selects id=cross-server-ready"

# Validate service has endpoint(s)
endpoint_ips=$(kubectl get endpointslice -n default -l kubernetes.io/service-name=service-am-i-ready -o jsonpath='{range .items[*].endpoints[*]}{.addresses[*]}{" "}{end}' 2>/dev/null || true)
[ -n "${endpoint_ips// }" ] || fail "Service service-am-i-ready has no endpoints"
pass "Service service-am-i-ready has endpoints"

# Validate first pod transitioned to Ready
ready_status=$(kubectl get pod ready-if-service-ready -n default -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}')
[ "$ready_status" = "True" ] || fail "Pod ready-if-service-ready is not Ready"
pass "Pod ready-if-service-ready is Ready"

echo "All validations passed"
