#!/bin/bash
set -euo pipefail

EP_COUNT=$(kubectl -n qv4-10 get endpoints api -o jsonpath='{range .subsets[*].addresses[*]}{.ip}{"\n"}{end}' | sed '/^$/d' | wc -l)
[ "$EP_COUNT" -ge 1 ] || { echo "FAIL: no service endpoints"; exit 1; }

kubectl -n qv4-10 exec debug -- curl -sS --max-time 5 http://api >/tmp/v4q10.out
grep -qi 'nginx' /tmp/v4q10.out || { echo "FAIL: service not reachable"; exit 1; }

echo "PASS: Question 10"
