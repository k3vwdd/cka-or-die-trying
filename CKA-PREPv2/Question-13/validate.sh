#!/bin/bash
set -euo pipefail

echo "Validating Question 13..."

NS=project-r500
HR=traffic-director

kubectl -n "$NS" get httproute "$HR" >/dev/null 2>&1 || { echo "FAIL: HTTPRoute missing"; exit 1; }

kubectl -n "$NS" get httproute "$HR" -o json > /tmp/q13-httproute.json

PARENT=$(kubectl -n "$NS" get httproute "$HR" -o jsonpath='{.spec.parentRefs[0].name}')
[ "$PARENT" = "main" ] || { echo "FAIL: HTTPRoute parentRef must be main"; exit 1; }
grep -Eq '"r500\.gateway"' /tmp/q13-httproute.json || { echo "FAIL: hostname r500.gateway missing"; exit 1; }

grep -Eq '"value"[[:space:]]*:[[:space:]]*"/desktop"' /tmp/q13-httproute.json || { echo "FAIL: /desktop path missing"; exit 1; }
grep -Eq '"name"[[:space:]]*:[[:space:]]*"web-desktop"' /tmp/q13-httproute.json || { echo "FAIL: desktop backend missing"; exit 1; }

grep -Eq '"value"[[:space:]]*:[[:space:]]*"/mobile"' /tmp/q13-httproute.json || { echo "FAIL: /mobile path missing"; exit 1; }
grep -Eq '"name"[[:space:]]*:[[:space:]]*"web-mobile"' /tmp/q13-httproute.json || { echo "FAIL: mobile backend missing"; exit 1; }

grep -Eq '"value"[[:space:]]*:[[:space:]]*"/auto"' /tmp/q13-httproute.json || { echo "FAIL: /auto path missing"; exit 1; }
grep -Eqi '"name"[[:space:]]*:[[:space:]]*"user-agent"' /tmp/q13-httproute.json || { echo "FAIL: user-agent header match missing"; exit 1; }
grep -Eq '"value"[[:space:]]*:[[:space:]]*"mobile"' /tmp/q13-httproute.json || { echo "FAIL: header value mobile missing"; exit 1; }

AUTO_RULES=$(grep -Eo '"value"[[:space:]]*:[[:space:]]*"/auto"' /tmp/q13-httproute.json | wc -l | tr -d ' ')
[ "$AUTO_RULES" -ge 2 ] || { echo "FAIL: expected two /auto rules (mobile + default)"; exit 1; }

echo "SUCCESS: Question 13 passed"
