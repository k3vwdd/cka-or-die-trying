#!/bin/bash
set -euo pipefail

READY=$(kubectl -n qv4-06 get deploy web -o jsonpath='{.status.readyReplicas}')
[ "${READY:-0}" = "2" ] || { echo "FAIL: ready replicas not 2"; exit 1; }

NOT_READY=$(kubectl -n qv4-06 get pods -l app=web --field-selector=status.phase!=Running --no-headers 2>/dev/null | wc -l)
[ "$NOT_READY" = "0" ] || { echo "FAIL: non-running pods remain"; exit 1; }

echo "PASS: Question 6"
