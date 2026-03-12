#!/bin/bash
set -euo pipefail

KCFG=/opt/course/v4/2/kubeconfig
[ -f /opt/course/v4/2/contexts ] || { echo "FAIL: contexts missing"; exit 1; }
[ -f /opt/course/v4/2/current-context ] || { echo "FAIL: current-context missing"; exit 1; }
[ -f /opt/course/v4/2/current-server ] || { echo "FAIL: current-server missing"; exit 1; }

EXPECTED_CONTEXT=$(kubectl --kubeconfig "$KCFG" config current-context)
ACTUAL_CONTEXT=$(cat /opt/course/v4/2/current-context)
[ "$EXPECTED_CONTEXT" = "$ACTUAL_CONTEXT" ] || { echo "FAIL: current-context mismatch"; exit 1; }

echo "PASS: Question 2"
