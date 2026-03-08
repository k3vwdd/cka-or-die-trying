#!/bin/bash
set -euo pipefail

pass() {
  echo "PASS: $1"
}

fail() {
  echo "FAIL: $1"
  exit 1
}

MANIFEST_PATH="/etc/kubernetes/manifests/my-static-pod.yaml"
NAMESPACE="default"
STATIC_POD_NAME="my-static-pod"
SERVICE_NAME="static-pod-service"
EXPECTED_IMAGE="nginx:1-alpine"
EXPECTED_CPU="10m"
EXPECTED_MEMORY="20Mi"

command -v kubectl >/dev/null 2>&1 || fail "kubectl not found"

[ -f "$MANIFEST_PATH" ] || fail "Static pod manifest not found at $MANIFEST_PATH"
pass "Static pod manifest exists"

grep -Eq '^\s*name:\s*my-static-pod\s*$' "$MANIFEST_PATH" || fail "Manifest does not define pod name my-static-pod"
pass "Manifest contains pod name my-static-pod"

grep -Eq '^\s*image:\s*nginx:1-alpine\s*$' "$MANIFEST_PATH" || fail "Manifest does not use image nginx:1-alpine"
pass "Manifest uses correct image"

grep -Eq '^\s*cpu:\s*10m\s*$' "$MANIFEST_PATH" || fail "Manifest does not contain cpu request 10m"
grep -Eq '^\s*memory:\s*20Mi\s*$' "$MANIFEST_PATH" || fail "Manifest does not contain memory request 20Mi"
pass "Manifest contains required resource requests"

POD_JSON=$(kubectl get pod -n "$NAMESPACE" "$STATIC_POD_NAME" -o json 2>/dev/null) || fail "Pod $STATIC_POD_NAME not found in namespace $NAMESPACE"
pass "Pod exists in default namespace"

POD_PHASE=$(kubectl get pod -n "$NAMESPACE" "$STATIC_POD_NAME" -o jsonpath='{.status.phase}')
[ "$POD_PHASE" = "Running" ] || fail "Pod is not Running (current phase: $POD_PHASE)"
pass "Pod is Running"

OWNER_KIND=$(kubectl get pod -n "$NAMESPACE" "$STATIC_POD_NAME" -o jsonpath='{.metadata.ownerReferences[0].kind}' 2>/dev/null || true)
if [ -n "$OWNER_KIND" ]; then
  fail "Pod has ownerReference kind $OWNER_KIND; expected a static pod without controller ownerReferences"
fi
pass "Pod appears to be a static pod"

POD_IMAGE=$(kubectl get pod -n "$NAMESPACE" "$STATIC_POD_NAME" -o jsonpath='{.spec.containers[0].image}')
[ "$POD_IMAGE" = "$EXPECTED_IMAGE" ] || fail "Pod image is $POD_IMAGE, expected $EXPECTED_IMAGE"
pass "Running pod uses correct image"

POD_CPU=$(kubectl get pod -n "$NAMESPACE" "$STATIC_POD_NAME" -o jsonpath='{.spec.containers[0].resources.requests.cpu}')
[ "$POD_CPU" = "$EXPECTED_CPU" ] || fail "Pod cpu request is $POD_CPU, expected $EXPECTED_CPU"
POD_MEM=$(kubectl get pod -n "$NAMESPACE" "$STATIC_POD_NAME" -o jsonpath='{.spec.containers[0].resources.requests.memory}')
[ "$POD_MEM" = "$EXPECTED_MEMORY" ] || fail "Pod memory request is $POD_MEM, expected $EXPECTED_MEMORY"
pass "Running pod has correct resource requests"

RUN_LABEL=$(kubectl get pod -n "$NAMESPACE" "$STATIC_POD_NAME" -o jsonpath='{.metadata.labels.run}' 2>/dev/null || true)
[ "$RUN_LABEL" = "$STATIC_POD_NAME" ] || fail "Pod label run=$RUN_LABEL, expected run=$STATIC_POD_NAME"
pass "Pod has expected run label"

kubectl get svc -n "$NAMESPACE" "$SERVICE_NAME" >/dev/null 2>&1 || fail "Service $SERVICE_NAME not found in namespace $NAMESPACE"
pass "Service exists"

SVC_TYPE=$(kubectl get svc -n "$NAMESPACE" "$SERVICE_NAME" -o jsonpath='{.spec.type}')
[ "$SVC_TYPE" = "NodePort" ] || fail "Service type is $SVC_TYPE, expected NodePort"
pass "Service type is NodePort"

SVC_PORT=$(kubectl get svc -n "$NAMESPACE" "$SERVICE_NAME" -o jsonpath='{.spec.ports[0].port}')
[ "$SVC_PORT" = "80" ] || fail "Service port is $SVC_PORT, expected 80"
pass "Service exposes port 80"

NODE_PORT=$(kubectl get svc -n "$NAMESPACE" "$SERVICE_NAME" -o jsonpath='{.spec.ports[0].nodePort}')
[ -n "$NODE_PORT" ] || fail "Service nodePort is empty"
pass "Service has assigned nodePort $NODE_PORT"

ENDPOINTS=$(kubectl get endpoints -n "$NAMESPACE" "$SERVICE_NAME" -o jsonpath='{range .subsets[*].addresses[*]}{.ip}{"\n"}{end}' 2>/dev/null || true)
ENDPOINT_COUNT=$(printf "%s\n" "$ENDPOINTS" | sed '/^$/d' | wc -l | tr -d ' ')
[ "$ENDPOINT_COUNT" = "1" ] || fail "Service has $ENDPOINT_COUNT endpoints, expected exactly 1"
pass "Service has exactly one endpoint"

SELECTOR_RUN=$(kubectl get svc -n "$NAMESPACE" "$SERVICE_NAME" -o jsonpath='{.spec.selector.run}' 2>/dev/null || true)
[ "$SELECTOR_RUN" = "$STATIC_POD_NAME" ] || fail "Service selector run=$SELECTOR_RUN, expected run=$STATIC_POD_NAME"
pass "Service selector targets the static pod"

CONTROLPLANE_NODE=$(kubectl get node -l node-role.kubernetes.io/control-plane -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)
[ -n "$CONTROLPLANE_NODE" ] || fail "Could not determine controlplane node using label node-role.kubernetes.io/control-plane"
pass "Detected controlplane node $CONTROLPLANE_NODE"

NODE_IP=$(kubectl get node "$CONTROLPLANE_NODE" -o jsonpath='{.status.addresses[?(@.type=="InternalIP")].address}')
[ -n "$NODE_IP" ] || fail "Could not determine InternalIP for controlplane node $CONTROLPLANE_NODE"
pass "Detected controlplane InternalIP $NODE_IP"

HTTP_BODY=$(curl -sS --max-time 10 "http://${NODE_IP}:${NODE_PORT}" 2>/dev/null || true)
[ -n "$HTTP_BODY" ] || fail "No response received from http://${NODE_IP}:${NODE_PORT}"
printf '%s' "$HTTP_BODY" | grep -qi 'nginx' || fail "Response from NodePort does not appear to be nginx content"
pass "Pod is reachable via controlplane InternalIP and NodePort"

echo "All validations passed."
