#!/bin/bash
set -euo pipefail

echo "Validating Question 3..."

kubectl -n project-h800 get sts o3db >/dev/null 2>&1 || { echo "FAIL: StatefulSet o3db missing"; exit 1; }

REPLICAS=$(kubectl -n project-h800 get sts o3db -o jsonpath='{.spec.replicas}')
[ "$REPLICAS" = "1" ] || { echo "FAIL: replicas=$REPLICAS expected 1"; exit 1; }

READY=$(kubectl -n project-h800 get sts o3db -o jsonpath='{.status.readyReplicas}')
[ "${READY:-0}" = "1" ] || { echo "FAIL: readyReplicas=${READY:-0} expected 1"; exit 1; }

echo "SUCCESS: Question 3 passed"
