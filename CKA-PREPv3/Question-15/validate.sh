#!/bin/bash
set -euo pipefail

BASE_DIR=/opt/course/15
SCRIPT_FILE="$BASE_DIR/cluster_events.sh"
POD_LOG="$BASE_DIR/pod_kill.log"
CONTAINER_LOG="$BASE_DIR/container_kill.log"

fail() {
  echo "[FAIL] $1"
  exit 1
}

pass() {
  echo "[PASS] $1"
}

[ -d "$BASE_DIR" ] || fail "Directory $BASE_DIR does not exist"
pass "Directory $BASE_DIR exists"

[ -f "$SCRIPT_FILE" ] || fail "$SCRIPT_FILE does not exist"
pass "$SCRIPT_FILE exists"

if ! grep -Fxq 'kubectl get events -A --sort-by=.metadata.creationTimestamp' "$SCRIPT_FILE"; then
  fail "$SCRIPT_FILE does not contain the expected kubectl command"
fi
pass "$SCRIPT_FILE contains the expected sorted cluster-wide events command"

if ! sh "$SCRIPT_FILE" >/dev/null 2>&1; then
  fail "$SCRIPT_FILE is not executable as a shell script or command fails"
fi
pass "$SCRIPT_FILE runs successfully"

[ -f "$POD_LOG" ] || fail "$POD_LOG does not exist"
[ -s "$POD_LOG" ] || fail "$POD_LOG exists but is empty"
pass "$POD_LOG exists and is not empty"

[ -f "$CONTAINER_LOG" ] || fail "$CONTAINER_LOG does not exist"
[ -s "$CONTAINER_LOG" ] || fail "$CONTAINER_LOG exists but is empty"
pass "$CONTAINER_LOG exists and is not empty"

if ! grep -qi 'kube-proxy' "$POD_LOG"; then
  fail "$POD_LOG does not appear to contain kube-proxy related events"
fi
pass "$POD_LOG contains kube-proxy related content"

if ! grep -qi 'kube-proxy' "$CONTAINER_LOG"; then
  fail "$CONTAINER_LOG does not appear to contain kube-proxy related events"
fi
pass "$CONTAINER_LOG contains kube-proxy related content"

CURRENT_KP_POD=$(kubectl -n kube-system get pods -l k8s-app=kube-proxy -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)
if [ -z "$CURRENT_KP_POD" ]; then
  fail "Could not find a kube-proxy pod in kube-system for post-check validation"
fi
pass "kube-proxy pod currently exists in kube-system: $CURRENT_KP_POD"

echo "Validation successful"
