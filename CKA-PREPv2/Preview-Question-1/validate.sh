#!/bin/bash
set -euo pipefail

echo "Validating Preview Question 1..."

[ -f /opt/course/p1/etcd-info.txt ] || { echo "FAIL: /opt/course/p1/etcd-info.txt missing"; exit 1; }

EXPECTED=$(cat /opt/course/p1/expected-etcd-info.txt)
ACTUAL=$(cat /opt/course/p1/etcd-info.txt)

[ "$EXPECTED" = "$ACTUAL" ] || {
  echo "FAIL: etcd info content is incorrect"
  echo "Expected:"
  cat /opt/course/p1/expected-etcd-info.txt
  echo "Actual:"
  cat /opt/course/p1/etcd-info.txt
  exit 1
}

echo "SUCCESS: Preview Question 1 passed"
