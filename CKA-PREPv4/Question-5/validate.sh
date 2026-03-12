#!/bin/bash
set -euo pipefail

[ -s /opt/course/v4/5/etcd-version.txt ] || { echo "FAIL: etcd version file missing/empty"; exit 1; }
[ -s /opt/course/v4/5/snapshot.db ] || { echo "FAIL: snapshot missing/empty"; exit 1; }

grep -qi 'etcd version' /opt/course/v4/5/etcd-version.txt || { echo "FAIL: etcd version output invalid"; exit 1; }

echo "PASS: Question 5"
