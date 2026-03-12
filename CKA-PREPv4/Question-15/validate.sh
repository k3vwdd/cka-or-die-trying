#!/bin/bash
set -euo pipefail

[ -f /opt/course/v4/15/cluster_events.sh ] || { echo "FAIL: cluster_events.sh missing"; exit 1; }
[ -s /opt/course/v4/15/pod-delete.log ] || { echo "FAIL: pod-delete.log empty"; exit 1; }
[ -s /opt/course/v4/15/container-kill.log ] || { echo "FAIL: container-kill.log empty"; exit 1; }

grep -q 'kubectl get events -A --sort-by=.metadata.creationTimestamp' /opt/course/v4/15/cluster_events.sh || {
  echo "FAIL: cluster_events.sh command incorrect"
  exit 1
}

echo "PASS: Question 15"
