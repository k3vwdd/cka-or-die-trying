#!/bin/bash
set -euo pipefail

READY=$(kubectl -n qv4-17 get deploy app -o jsonpath='{.status.readyReplicas}')
[ "${READY:-0}" = "2" ] || { echo "FAIL: app not fully ready"; exit 1; }

EP_COUNT=$(kubectl -n qv4-17 get endpoints app-svc -o jsonpath='{range .subsets[*].addresses[*]}{.ip}{"\n"}{end}' | sed '/^$/d' | wc -l)
[ "$EP_COUNT" -ge 1 ] || { echo "FAIL: app-svc has no endpoints"; exit 1; }

kubectl -n qv4-17 exec tester -- curl -sS --max-time 5 http://app-svc >/tmp/v4q17-ok.out
grep -qi 'nginx' /tmp/v4q17-ok.out || { echo "FAIL: tester cannot reach app-svc"; exit 1; }

if kubectl -n qv4-17 exec intruder -- curl -sS --max-time 5 http://app-svc >/tmp/v4q17-bad.out 2>/dev/null; then
  echo "FAIL: intruder should be blocked"
  exit 1
fi

echo "PASS: Question 17"
