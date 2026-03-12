#!/bin/bash
set -euo pipefail

kubectl -n qv4-13 get netpol allow-client >/dev/null 2>&1 || { echo "FAIL: allow-client missing"; exit 1; }

kubectl -n qv4-13 exec client -- curl -sS --max-time 5 http://app-svc >/tmp/v4q13-client.out
grep -qi 'nginx' /tmp/v4q13-client.out || { echo "FAIL: client cannot reach app"; exit 1; }

if kubectl -n qv4-13 exec stranger -- curl -sS --max-time 5 http://app-svc >/tmp/v4q13-stranger.out 2>/dev/null; then
  echo "FAIL: stranger should not have access"
  exit 1
fi

echo "PASS: Question 13"
