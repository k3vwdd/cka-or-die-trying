#!/bin/bash
set -euo pipefail

kubectl -n qv4-12 get svc web-internal >/dev/null 2>&1 || { echo "FAIL: service web-internal missing"; exit 1; }

READY=$(kubectl -n qv4-12 get pod dns-check -o jsonpath='{.status.containerStatuses[0].ready}' 2>/dev/null || true)
[ "$READY" = "true" ] || { echo "FAIL: dns-check not Ready"; exit 1; }

echo "PASS: Question 12"
