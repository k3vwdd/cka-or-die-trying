#!/bin/bash
set -euo pipefail

echo "Validating Question 12..."

NS=project-tiger
DEPLOY=deploy-important

kubectl -n "$NS" get deploy "$DEPLOY" >/dev/null 2>&1 || { echo "FAIL: deployment missing"; exit 1; }

REPLICAS=$(kubectl -n "$NS" get deploy "$DEPLOY" -o jsonpath='{.spec.replicas}')
[ "$REPLICAS" = "3" ] || { echo "FAIL: replicas=$REPLICAS expected 3"; exit 1; }

DEPLOY_LABEL=$(kubectl -n "$NS" get deploy "$DEPLOY" -o jsonpath='{.metadata.labels.id}')
POD_LABEL=$(kubectl -n "$NS" get deploy "$DEPLOY" -o jsonpath='{.spec.template.metadata.labels.id}')
[ "$DEPLOY_LABEL" = "very-important" ] || { echo "FAIL: deployment label id incorrect"; exit 1; }
[ "$POD_LABEL" = "very-important" ] || { echo "FAIL: pod template label id incorrect"; exit 1; }

C1_NAME=$(kubectl -n "$NS" get deploy "$DEPLOY" -o jsonpath='{.spec.template.spec.containers[0].name}')
C1_IMG=$(kubectl -n "$NS" get deploy "$DEPLOY" -o jsonpath='{.spec.template.spec.containers[0].image}')
C2_NAME=$(kubectl -n "$NS" get deploy "$DEPLOY" -o jsonpath='{.spec.template.spec.containers[1].name}')
C2_IMG=$(kubectl -n "$NS" get deploy "$DEPLOY" -o jsonpath='{.spec.template.spec.containers[1].image}')
CONTAINER_COUNT=$(kubectl -n "$NS" get deploy "$DEPLOY" -o jsonpath='{.spec.template.spec.containers[*].name}' | wc -w | tr -d ' ')
[ "$C1_NAME" = "container1" ] || { echo "FAIL: first container name must be container1"; exit 1; }
[ "$C1_IMG" = "nginx:1-alpine" ] || { echo "FAIL: first container image incorrect"; exit 1; }
[ "$C2_NAME" = "container2" ] || { echo "FAIL: second container name must be container2"; exit 1; }
[ "$C2_IMG" = "google/pause" ] || { echo "FAIL: second container image incorrect"; exit 1; }
[ "$CONTAINER_COUNT" = "2" ] || { echo "FAIL: deployment must define exactly two containers"; exit 1; }

ANTI_TOPO=$(kubectl -n "$NS" get deploy "$DEPLOY" -o jsonpath='{.spec.template.spec.affinity.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution[0].topologyKey}')
SPREAD_TOPO=$(kubectl -n "$NS" get deploy "$DEPLOY" -o jsonpath='{.spec.template.spec.topologySpreadConstraints[0].topologyKey}')

if [ "$ANTI_TOPO" != "kubernetes.io/hostname" ] && [ "$SPREAD_TOPO" != "kubernetes.io/hostname" ]; then
  echo "FAIL: missing topologyKey kubernetes.io/hostname in anti-affinity or topology spread"
  exit 1
fi

echo "SUCCESS: Question 12 passed"
