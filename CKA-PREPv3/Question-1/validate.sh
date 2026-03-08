#!/bin/bash
set -euo pipefail

pass() {
  echo "PASS: $1"
}

fail() {
  echo "FAIL: $1"
  exit 1
}

require_resource() {
  local cmd="$1"
  local msg="$2"
  eval "$cmd" >/dev/null 2>&1 || fail "$msg"
}

require_resource "kubectl get ns lima-control" "Namespace lima-control not found"
require_resource "kubectl get ns lima-workload" "Namespace lima-workload not found"
require_resource "kubectl -n lima-control get configmap control-config" "ConfigMap control-config not found in namespace lima-control"
require_resource "kubectl -n lima-control get deployment controller" "Deployment controller not found in namespace lima-control"
require_resource "kubectl -n lima-workload get pod section100" "Pod section100 not found in namespace lima-workload"
require_resource "kubectl -n lima-workload get svc department" "Service department not found in namespace lima-workload"
require_resource "kubectl -n lima-workload get svc section" "Service section not found in namespace lima-workload"

DNS_1=$(kubectl -n lima-control get configmap control-config -o jsonpath='{.data.DNS_1}' 2>/dev/null || true)
DNS_2=$(kubectl -n lima-control get configmap control-config -o jsonpath='{.data.DNS_2}' 2>/dev/null || true)
DNS_3=$(kubectl -n lima-control get configmap control-config -o jsonpath='{.data.DNS_3}' 2>/dev/null || true)
DNS_4=$(kubectl -n lima-control get configmap control-config -o jsonpath='{.data.DNS_4}' 2>/dev/null || true)

[[ "$DNS_1" == "kubernetes.default.svc.cluster.local" ]] || fail "ConfigMap control-config key DNS_1 is incorrect. Expected kubernetes.default.svc.cluster.local, got: ${DNS_1:-<empty>}"
pass "ConfigMap DNS_1 is correct"

[[ "$DNS_2" == "department.lima-workload.svc.cluster.local" ]] || fail "ConfigMap control-config key DNS_2 is incorrect. Expected department.lima-workload.svc.cluster.local, got: ${DNS_2:-<empty>}"
pass "ConfigMap DNS_2 is correct"

[[ "$DNS_3" == "section100.section.lima-workload.svc.cluster.local" ]] || fail "ConfigMap control-config key DNS_3 is incorrect. Expected section100.section.lima-workload.svc.cluster.local, got: ${DNS_3:-<empty>}"
pass "ConfigMap DNS_3 is correct"

[[ "$DNS_4" == "1-2-3-4.kube-system.pod.cluster.local" ]] || fail "ConfigMap control-config key DNS_4 is incorrect. Expected 1-2-3-4.kube-system.pod.cluster.local, got: ${DNS_4:-<empty>}"
pass "ConfigMap DNS_4 is correct"

DEPT_CLUSTER_IP=$(kubectl -n lima-workload get svc department -o jsonpath='{.spec.clusterIP}')
[[ "$DEPT_CLUSTER_IP" == "None" ]] || fail "Service department must be headless but clusterIP is ${DEPT_CLUSTER_IP:-<empty>}"
pass "Service department is headless"

SECTION_CLUSTER_IP=$(kubectl -n lima-workload get svc section -o jsonpath='{.spec.clusterIP}')
[[ "$SECTION_CLUSTER_IP" == "None" ]] || fail "Service section must be headless for stable Pod DNS but clusterIP is ${SECTION_CLUSTER_IP:-<empty>}"
pass "Service section is headless"

SECTION_HOSTNAME=$(kubectl -n lima-workload get pod section100 -o jsonpath='{.spec.hostname}' 2>/dev/null || true)
SECTION_SUBDOMAIN=$(kubectl -n lima-workload get pod section100 -o jsonpath='{.spec.subdomain}' 2>/dev/null || true)
[[ "$SECTION_HOSTNAME" == "section100" ]] || fail "Pod section100 must have spec.hostname=section100 to match required DNS. Found: ${SECTION_HOSTNAME:-<empty>}"
[[ "$SECTION_SUBDOMAIN" == "section" ]] || fail "Pod section100 must have spec.subdomain=section to match required DNS. Found: ${SECTION_SUBDOMAIN:-<empty>}"
pass "Pod section100 hostname and subdomain support stable Pod DNS"

EXPECTED_ENV_NAMES=(DNS_1 DNS_2 DNS_3 DNS_4)
for name in "${EXPECTED_ENV_NAMES[@]}"; do
  count=$(kubectl -n lima-control get deployment controller -o json | jq -r --arg NAME "$name" '[.spec.template.spec.containers[].env[]? | select(.name==$NAME and .valueFrom.configMapKeyRef.name=="control-config" and .valueFrom.configMapKeyRef.key==$NAME)] | length')
  [[ "$count" -ge 1 ]] || fail "Deployment controller does not reference ConfigMap control-config key $name through env"
done
pass "Deployment controller references control-config keys via env"

ROLLOUT_OK=0
if kubectl -n lima-control rollout status deployment controller --timeout=120s >/dev/null 2>&1; then
  ROLLOUT_OK=1
fi
[[ "$ROLLOUT_OK" -eq 1 ]] || fail "Deployment controller is not successfully rolled out"
pass "Deployment controller rollout is healthy"

READY_REPLICAS=$(kubectl -n lima-control get deployment controller -o jsonpath='{.status.readyReplicas}' 2>/dev/null || true)
DESIRED_REPLICAS=$(kubectl -n lima-control get deployment controller -o jsonpath='{.spec.replicas}' 2>/dev/null || true)
[[ -n "${DESIRED_REPLICAS}" ]] || fail "Could not determine desired replicas for deployment controller"
[[ "${READY_REPLICAS:-0}" == "$DESIRED_REPLICAS" ]] || fail "Deployment controller does not have all replicas ready (${READY_REPLICAS:-0}/${DESIRED_REPLICAS})"
pass "Deployment controller has all replicas ready"

POD_NAME=$(kubectl -n lima-control get pods -l app=controller -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)
[[ -n "$POD_NAME" ]] || fail "No controller pod found with label app=controller in namespace lima-control"
pass "Found a controller pod for runtime validation"

kubectl -n lima-control exec "$POD_NAME" -- printenv DNS_1 2>/dev/null | grep -Fx "kubernetes.default.svc.cluster.local" >/dev/null || fail "Controller pod environment DNS_1 does not contain expected value"
pass "Controller pod env DNS_1 is correct"

kubectl -n lima-control exec "$POD_NAME" -- printenv DNS_2 2>/dev/null | grep -Fx "department.lima-workload.svc.cluster.local" >/dev/null || fail "Controller pod environment DNS_2 does not contain expected value"
pass "Controller pod env DNS_2 is correct"

kubectl -n lima-control exec "$POD_NAME" -- printenv DNS_3 2>/dev/null | grep -Fx "section100.section.lima-workload.svc.cluster.local" >/dev/null || fail "Controller pod environment DNS_3 does not contain expected value"
pass "Controller pod env DNS_3 is correct"

kubectl -n lima-control exec "$POD_NAME" -- printenv DNS_4 2>/dev/null | grep -Fx "1-2-3-4.kube-system.pod.cluster.local" >/dev/null || fail "Controller pod environment DNS_4 does not contain expected value"
pass "Controller pod env DNS_4 is correct"

kubectl -n lima-control exec "$POD_NAME" -- sh -c 'command -v nslookup >/dev/null 2>&1 && nslookup kubernetes.default.svc.cluster.local >/dev/null 2>&1' || fail "DNS lookup failed for kubernetes.default.svc.cluster.local from controller pod"
pass "DNS_1 resolves from controller pod"

kubectl -n lima-control exec "$POD_NAME" -- sh -c 'command -v nslookup >/dev/null 2>&1 && nslookup department.lima-workload.svc.cluster.local >/dev/null 2>&1' || fail "DNS lookup failed for department.lima-workload.svc.cluster.local from controller pod"
pass "DNS_2 resolves from controller pod"

kubectl -n lima-control exec "$POD_NAME" -- sh -c 'command -v nslookup >/dev/null 2>&1 && nslookup section100.section.lima-workload.svc.cluster.local >/dev/null 2>&1' || fail "DNS lookup failed for section100.section.lima-workload.svc.cluster.local from controller pod"
pass "DNS_3 resolves from controller pod"

kubectl -n lima-control exec "$POD_NAME" -- sh -c 'command -v nslookup >/dev/null 2>&1 && nslookup 1-2-3-4.kube-system.pod.cluster.local >/dev/null 2>&1' || fail "DNS lookup failed for 1-2-3-4.kube-system.pod.cluster.local from controller pod"
pass "DNS_4 resolves from controller pod"

echo "Validation completed successfully"
