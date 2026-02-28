#!/bin/bash
set -euo pipefail

echo "Validating Question 15..."

NS=project-snake
NP=np-backend

kubectl -n "$NS" get networkpolicy "$NP" >/dev/null 2>&1 || { echo "FAIL: networkpolicy np-backend missing"; exit 1; }
kubectl -n "$NS" get networkpolicy "$NP" -o json > /tmp/q15-np.json

BACKEND_SELECTOR=$(kubectl -n "$NS" get networkpolicy "$NP" -o jsonpath='{.spec.podSelector.matchLabels.app}')
[ "$BACKEND_SELECTOR" = "backend" ] || { echo "FAIL: podSelector app=$BACKEND_SELECTOR expected backend"; exit 1; }
grep -Eq '"policyTypes"[[:space:]]*:[[:space:]]*\[[[:space:]]*"Egress"[[:space:]]*\]' /tmp/q15-np.json || { echo "FAIL: policyTypes must be Egress only"; exit 1; }

grep -Eq '"app"[[:space:]]*:[[:space:]]*"db1"' /tmp/q15-np.json || { echo "FAIL: db1 target missing"; exit 1; }
grep -Eq '"port"[[:space:]]*:[[:space:]]*1111' /tmp/q15-np.json || { echo "FAIL: port 1111 missing"; exit 1; }

grep -Eq '"app"[[:space:]]*:[[:space:]]*"db2"' /tmp/q15-np.json || { echo "FAIL: db2 target missing"; exit 1; }
grep -Eq '"port"[[:space:]]*:[[:space:]]*2222' /tmp/q15-np.json || { echo "FAIL: port 2222 missing"; exit 1; }

RULE_COUNT=$(kubectl -n "$NS" get networkpolicy "$NP" -o jsonpath='{.spec.egress[*].to[*].podSelector.matchLabels.app}' | wc -w | tr -d ' ')
[ "$RULE_COUNT" = "2" ] || { echo "FAIL: expected exactly 2 egress destinations, got $RULE_COUNT"; exit 1; }

grep -Eq '"app"[[:space:]]*:[[:space:]]*"vault"' /tmp/q15-np.json && { echo "FAIL: policy should not include vault"; exit 1; }
grep -Eq '"port"[[:space:]]*:[[:space:]]*3333' /tmp/q15-np.json && { echo "FAIL: policy should not allow port 3333"; exit 1; }

echo "SUCCESS: Question 15 passed"
