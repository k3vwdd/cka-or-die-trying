#!/bin/bash
set -euo pipefail

echo "Validating Question 1..."

[ -f /opt/course/1/contexts ] || { echo "FAIL: /opt/course/1/contexts missing"; exit 1; }
[ -f /opt/course/1/current-context ] || { echo "FAIL: /opt/course/1/current-context missing"; exit 1; }
[ -f /opt/course/1/cert ] || { echo "FAIL: /opt/course/1/cert missing"; exit 1; }

EXPECTED_CONTEXTS=$(kubectl --kubeconfig /opt/course/1/kubeconfig config get-contexts -o name | sort)
ACTUAL_CONTEXTS=$(sort /opt/course/1/contexts)
[ "$EXPECTED_CONTEXTS" = "$ACTUAL_CONTEXTS" ] || { echo "FAIL: contexts file content incorrect"; exit 1; }

EXPECTED_CURRENT=$(kubectl --kubeconfig /opt/course/1/kubeconfig config current-context)
ACTUAL_CURRENT=$(cat /opt/course/1/current-context)
[ "$EXPECTED_CURRENT" = "$ACTUAL_CURRENT" ] || { echo "FAIL: current-context incorrect"; exit 1; }

EXPECTED_B64=$(kubectl --kubeconfig /opt/course/1/kubeconfig config view --raw \
  -o jsonpath="{.users[?(@.name=='account-0027@internal')].user.client-certificate-data}")

[ -n "$EXPECTED_B64" ] || { echo "FAIL: could not locate client-certificate-data for account-0027@internal"; exit 1; }

TMP_EXPECTED=$(mktemp)
trap 'rm -f "$TMP_EXPECTED"' EXIT
printf "%s" "$EXPECTED_B64" | base64 -d > "$TMP_EXPECTED"
cmp -s /opt/course/1/cert "$TMP_EXPECTED" || { echo "FAIL: decoded certificate content incorrect"; exit 1; }

echo "SUCCESS: Question 1 passed"
