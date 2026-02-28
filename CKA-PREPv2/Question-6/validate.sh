#!/bin/bash
set -euo pipefail

echo "Validating Question 6..."

kubectl get pv safari-pv >/dev/null 2>&1 || { echo "FAIL: PV safari-pv missing"; exit 1; }
PV_SIZE=$(kubectl get pv safari-pv -o jsonpath='{.spec.capacity.storage}')
PV_MODE=$(kubectl get pv safari-pv -o jsonpath='{.spec.accessModes[0]}')
PV_PATH=$(kubectl get pv safari-pv -o jsonpath='{.spec.hostPath.path}')
[ "$PV_SIZE" = "2Gi" ] || { echo "FAIL: PV size=$PV_SIZE expected 2Gi"; exit 1; }
[ "$PV_MODE" = "ReadWriteOnce" ] || { echo "FAIL: PV mode=$PV_MODE expected ReadWriteOnce"; exit 1; }
[ "$PV_PATH" = "/Volumes/Data" ] || { echo "FAIL: PV hostPath=$PV_PATH expected /Volumes/Data"; exit 1; }

kubectl -n project-t230 get pvc safari-pvc >/dev/null 2>&1 || { echo "FAIL: PVC safari-pvc missing"; exit 1; }
PVC_SIZE=$(kubectl -n project-t230 get pvc safari-pvc -o jsonpath='{.spec.resources.requests.storage}')
[ "$PVC_SIZE" = "2Gi" ] || { echo "FAIL: PVC size=$PVC_SIZE expected 2Gi"; exit 1; }
PVC_VOL=$(kubectl -n project-t230 get pvc safari-pvc -o jsonpath='{.spec.volumeName}')
[ "$PVC_VOL" = "safari-pv" ] || { echo "FAIL: PVC bound volume=$PVC_VOL expected safari-pv"; exit 1; }

kubectl -n project-t230 get deploy safari >/dev/null 2>&1 || { echo "FAIL: deployment safari missing"; exit 1; }
CLAIM=$(kubectl -n project-t230 get deploy safari -o jsonpath='{.spec.template.spec.volumes[0].persistentVolumeClaim.claimName}')
MOUNT=$(kubectl -n project-t230 get deploy safari -o jsonpath='{.spec.template.spec.containers[0].volumeMounts[0].mountPath}')
IMAGE=$(kubectl -n project-t230 get deploy safari -o jsonpath='{.spec.template.spec.containers[0].image}')
[ "$CLAIM" = "safari-pvc" ] || { echo "FAIL: deployment does not use safari-pvc"; exit 1; }
[ "$MOUNT" = "/tmp/safari-data" ] || { echo "FAIL: mountPath=$MOUNT expected /tmp/safari-data"; exit 1; }
[ "$IMAGE" = "httpd:2-alpine" ] || { echo "FAIL: deployment image=$IMAGE expected httpd:2-alpine"; exit 1; }

echo "SUCCESS: Question 6 passed"
