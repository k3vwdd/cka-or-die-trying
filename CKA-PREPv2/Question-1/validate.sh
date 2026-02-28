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

cmp -s /opt/course/1/cert /opt/course/1/expected-cert.pem || { echo "FAIL: decoded certificate content incorrect"; exit 1; }

echo "SUCCESS: Question 1 passed"
