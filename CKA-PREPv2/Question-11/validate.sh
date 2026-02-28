#!/bin/bash
set -euo pipefail

echo "Validating Question 11..."

NS=project-tiger
DS=ds-important
UUID=18426a0b-5f59-4e10-923f-c0e078e82462

kubectl -n "$NS" get ds "$DS" >/dev/null 2>&1 || { echo "FAIL: DaemonSet ds-important missing"; exit 1; }

ID_LABEL=$(kubectl -n "$NS" get ds "$DS" -o jsonpath='{.metadata.labels.id}')
UUID_LABEL=$(kubectl -n "$NS" get ds "$DS" -o jsonpath='{.metadata.labels.uuid}')
IMG=$(kubectl -n "$NS" get ds "$DS" -o jsonpath='{.spec.template.spec.containers[0].image}')
CPU_REQ=$(kubectl -n "$NS" get ds "$DS" -o jsonpath='{.spec.template.spec.containers[0].resources.requests.cpu}')
MEM_REQ=$(kubectl -n "$NS" get ds "$DS" -o jsonpath='{.spec.template.spec.containers[0].resources.requests.memory}')
TOL_EFFECT=$(kubectl -n "$NS" get ds "$DS" -o jsonpath='{.spec.template.spec.tolerations[0].effect}')
TOL_KEY=$(kubectl -n "$NS" get ds "$DS" -o jsonpath='{.spec.template.spec.tolerations[0].key}')
SEL_ID=$(kubectl -n "$NS" get ds "$DS" -o jsonpath='{.spec.selector.matchLabels.id}')
SEL_UUID=$(kubectl -n "$NS" get ds "$DS" -o jsonpath='{.spec.selector.matchLabels.uuid}')
DESIRED=$(kubectl -n "$NS" get ds "$DS" -o jsonpath='{.status.desiredNumberScheduled}')
READY=$(kubectl -n "$NS" get ds "$DS" -o jsonpath='{.status.numberReady}')

[ "$ID_LABEL" = "ds-important" ] || { echo "FAIL: id label incorrect"; exit 1; }
[ "$UUID_LABEL" = "$UUID" ] || { echo "FAIL: uuid label incorrect"; exit 1; }
[ "$SEL_ID" = "ds-important" ] || { echo "FAIL: selector id label incorrect"; exit 1; }
[ "$SEL_UUID" = "$UUID" ] || { echo "FAIL: selector uuid label incorrect"; exit 1; }
[ "$IMG" = "httpd:2-alpine" ] || { echo "FAIL: image=$IMG expected httpd:2-alpine"; exit 1; }
[ "$CPU_REQ" = "10m" ] || { echo "FAIL: cpu request=$CPU_REQ expected 10m"; exit 1; }
[ "$MEM_REQ" = "10Mi" ] || { echo "FAIL: memory request=$MEM_REQ expected 10Mi"; exit 1; }
[ "$TOL_KEY" = "node-role.kubernetes.io/control-plane" ] || { echo "FAIL: toleration key incorrect"; exit 1; }
[ "$TOL_EFFECT" = "NoSchedule" ] || { echo "FAIL: toleration effect incorrect"; exit 1; }
[ "${DESIRED:-0}" -ge 1 ] || { echo "FAIL: desiredNumberScheduled must be at least 1"; exit 1; }
[ "$DESIRED" = "$READY" ] || { echo "FAIL: daemonset ready pods ($READY) must equal desired ($DESIRED)"; exit 1; }

echo "SUCCESS: Question 11 passed"
