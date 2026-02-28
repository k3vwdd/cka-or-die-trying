#!/bin/bash
set -euo pipefail

echo "Validating Preview Question 2..."

kubectl -n project-hamster get pod p2-pod >/dev/null 2>&1 || { echo "FAIL: pod p2-pod missing"; exit 1; }
kubectl -n project-hamster get svc p2-service >/dev/null 2>&1 && { echo "FAIL: service p2-service should be deleted"; exit 1; }

[ -f /opt/course/p2/iptables.txt ] || { echo "FAIL: /opt/course/p2/iptables.txt missing"; exit 1; }

grep -q 'p2-service' /opt/course/p2/iptables.txt || { echo "FAIL: iptables.txt does not contain p2-service rules"; exit 1; }
LINES=$(wc -l < /opt/course/p2/iptables.txt | tr -d ' ')
[ "$LINES" -ge 1 ] || { echo "FAIL: iptables.txt must contain at least one matching rule"; exit 1; }

if sudo iptables-save | grep -q 'p2-service'; then
  echo "FAIL: live iptables still contains p2-service rules"
  exit 1
fi

echo "SUCCESS: Preview Question 2 passed"
