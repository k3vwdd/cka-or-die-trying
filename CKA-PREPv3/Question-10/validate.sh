#!/bin/bash
set -euo pipefail

SC_NAME="local-backup"
NS="project-bern"
PVC_NAME="backup-pvc"
JOB_NAME="backup"
FILE="/opt/course/10/backup.yaml"

fail() {
  echo "FAIL: $1"
  exit 1
}

pass() {
  echo "PASS: $1"
}

kubectl get storageclass "$SC_NAME" >/dev/null 2>&1 || fail "StorageClass $SC_NAME not found"

SC_PROVISIONER=$(kubectl get storageclass "$SC_NAME" -o jsonpath='{.provisioner}')
[ "$SC_PROVISIONER" = "rancher.io/local-path" ] || fail "StorageClass provisioner is $SC_PROVISIONER, expected rancher.io/local-path"
pass "StorageClass provisioner is correct"

SC_RECLAIM=$(kubectl get storageclass "$SC_NAME" -o jsonpath='{.reclaimPolicy}')
[ "$SC_RECLAIM" = "Retain" ] || fail "StorageClass reclaimPolicy is $SC_RECLAIM, expected Retain"
pass "StorageClass reclaimPolicy is correct"

SC_BINDING=$(kubectl get storageclass "$SC_NAME" -o jsonpath='{.volumeBindingMode}')
[ "$SC_BINDING" = "WaitForFirstConsumer" ] || fail "StorageClass volumeBindingMode is $SC_BINDING, expected WaitForFirstConsumer"
pass "StorageClass volumeBindingMode is correct"

[ -f "$FILE" ] || fail "$FILE does not exist"

grep -q "kind: PersistentVolumeClaim" "$FILE" || fail "$FILE does not contain a PersistentVolumeClaim manifest"
grep -q "name: $PVC_NAME" "$FILE" || fail "$FILE does not define PVC named $PVC_NAME"
grep -q "namespace: $NS" "$FILE" || fail "$FILE does not define namespace $NS"
grep -q "storageClassName: $SC_NAME" "$FILE" || fail "$FILE does not reference storageClassName $SC_NAME"
grep -q "storage: 50Mi" "$FILE" || fail "$FILE does not request 50Mi storage"
grep -q "claimName: $PVC_NAME" "$FILE" || fail "$FILE does not mount PVC $PVC_NAME in the Job"
if grep -A3 -B1 "name: backup" "$FILE" | grep -q "emptyDir:"; then
  fail "$FILE still appears to use emptyDir for the backup volume"
fi
pass "backup.yaml appears updated to use PVC"

kubectl -n "$NS" get pvc "$PVC_NAME" >/dev/null 2>&1 || fail "PVC $PVC_NAME not found in namespace $NS"
PVC_PHASE=$(kubectl -n "$NS" get pvc "$PVC_NAME" -o jsonpath='{.status.phase}')
[ "$PVC_PHASE" = "Bound" ] || fail "PVC $PVC_NAME phase is $PVC_PHASE, expected Bound"
pass "PVC is Bound"

PVC_SC=$(kubectl -n "$NS" get pvc "$PVC_NAME" -o jsonpath='{.spec.storageClassName}')
[ "$PVC_SC" = "$SC_NAME" ] || fail "PVC storageClassName is $PVC_SC, expected $SC_NAME"
pass "PVC storageClassName is correct"

PVC_SIZE=$(kubectl -n "$NS" get pvc "$PVC_NAME" -o jsonpath='{.spec.resources.requests.storage}')
[ "$PVC_SIZE" = "50Mi" ] || fail "PVC requested size is $PVC_SIZE, expected 50Mi"
pass "PVC requested size is correct"

PV_NAME=$(kubectl -n "$NS" get pvc "$PVC_NAME" -o jsonpath='{.spec.volumeName}')
[ -n "$PV_NAME" ] || fail "PVC $PVC_NAME is not bound to any PV"

kubectl get pv "$PV_NAME" >/dev/null 2>&1 || fail "Bound PV $PV_NAME not found"
pass "PVC is bound to PV $PV_NAME"

PV_PHASE=$(kubectl get pv "$PV_NAME" -o jsonpath='{.status.phase}')
[ "$PV_PHASE" = "Bound" ] || fail "PV $PV_NAME phase is $PV_PHASE, expected Bound"
pass "PV is Bound"

PV_SC=$(kubectl get pv "$PV_NAME" -o jsonpath='{.spec.storageClassName}')
[ "$PV_SC" = "$SC_NAME" ] || fail "PV storageClassName is $PV_SC, expected $SC_NAME"
pass "PV storageClassName is correct"

PV_CLAIM_NS=$(kubectl get pv "$PV_NAME" -o jsonpath='{.spec.claimRef.namespace}')
PV_CLAIM_NAME=$(kubectl get pv "$PV_NAME" -o jsonpath='{.spec.claimRef.name}')
[ "$PV_CLAIM_NS" = "$NS" ] || fail "PV claimRef namespace is $PV_CLAIM_NS, expected $NS"
[ "$PV_CLAIM_NAME" = "$PVC_NAME" ] || fail "PV claimRef name is $PV_CLAIM_NAME, expected $PVC_NAME"
pass "PV is correctly bound to the target PVC"

kubectl -n "$NS" get job "$JOB_NAME" >/dev/null 2>&1 || fail "Job $JOB_NAME not found in namespace $NS"

JOB_SUCCEEDED=$(kubectl -n "$NS" get job "$JOB_NAME" -o jsonpath='{.status.succeeded}')
[ "${JOB_SUCCEEDED:-0}" = "1" ] || fail "Job $JOB_NAME has succeeded count ${JOB_SUCCEEDED:-0}, expected 1"
pass "Job completed once"

JOB_ACTIVE=$(kubectl -n "$NS" get job "$JOB_NAME" -o jsonpath='{.status.active}')
[ -z "${JOB_ACTIVE:-}" ] || [ "$JOB_ACTIVE" = "0" ] || fail "Job $JOB_NAME is still active"
pass "Job is no longer active"

JOB_FAILED=$(kubectl -n "$NS" get job "$JOB_NAME" -o jsonpath='{.status.failed}')
[ -z "${JOB_FAILED:-}" ] || [ "$JOB_FAILED" = "0" ] || fail "Job $JOB_NAME has failures"
pass "Job has no failures"

echo "All validations passed"
