#!/bin/bash
set -euo pipefail

echo "Validating Question 16..."

[ -f /opt/course/16/coredns_backup.yaml ] || { echo "FAIL: backup file missing"; exit 1; }

grep -q 'name: coredns' /opt/course/16/coredns_backup.yaml || { echo "FAIL: backup does not appear to be coredns configmap"; exit 1; }
grep -q 'Corefile:' /opt/course/16/coredns_backup.yaml || { echo "FAIL: backup missing Corefile data"; exit 1; }

CURRENT_CORE=$(kubectl -n kube-system get cm coredns -o jsonpath='{.data.Corefile}')
echo "$CURRENT_CORE" | grep -Eq 'kubernetes[[:space:]]+.*cluster\.local.*custom-domain|kubernetes[[:space:]]+.*custom-domain.*cluster\.local' \
  || { echo "FAIL: CoreDNS does not include custom-domain with cluster.local"; exit 1; }

READY_COREDNS=$(kubectl -n kube-system get deploy coredns -o jsonpath='{.status.readyReplicas}')
[ "${READY_COREDNS:-0}" -ge 1 ] || { echo "FAIL: coredns has no ready replicas"; exit 1; }

echo "SUCCESS: Question 16 passed"
