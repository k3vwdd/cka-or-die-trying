#!/bin/bash
set -euo pipefail

echo "Validating Question 5..."

for ns in api-gateway-staging api-gateway-prod; do
  kubectl get ns "$ns" >/dev/null 2>&1 || { echo "FAIL: namespace $ns missing"; exit 1; }
  kubectl -n "$ns" get hpa api-gateway >/dev/null 2>&1 || { echo "FAIL: HPA api-gateway missing in $ns"; exit 1; }
  kubectl -n "$ns" get cm horizontal-scaling-config >/dev/null 2>&1 && { echo "FAIL: legacy ConfigMap still exists in $ns"; exit 1; }

  TARGET_KIND=$(kubectl -n "$ns" get hpa api-gateway -o jsonpath='{.spec.scaleTargetRef.kind}')
  TARGET_NAME=$(kubectl -n "$ns" get hpa api-gateway -o jsonpath='{.spec.scaleTargetRef.name}')
  TARGET_API=$(kubectl -n "$ns" get hpa api-gateway -o jsonpath='{.spec.scaleTargetRef.apiVersion}')
  [ "$TARGET_KIND" = "Deployment" ] || { echo "FAIL: $ns HPA target kind=$TARGET_KIND expected Deployment"; exit 1; }
  [ "$TARGET_NAME" = "api-gateway" ] || { echo "FAIL: $ns HPA target name=$TARGET_NAME expected api-gateway"; exit 1; }
  [ "$TARGET_API" = "apps/v1" ] || { echo "FAIL: $ns HPA target apiVersion=$TARGET_API expected apps/v1"; exit 1; }
done

MIN_STG=$(kubectl -n api-gateway-staging get hpa api-gateway -o jsonpath='{.spec.minReplicas}')
MAX_STG=$(kubectl -n api-gateway-staging get hpa api-gateway -o jsonpath='{.spec.maxReplicas}')
CPU_STG=$(kubectl -n api-gateway-staging get hpa api-gateway -o jsonpath='{.spec.metrics[0].resource.target.averageUtilization}')

[ "$MIN_STG" = "2" ] || { echo "FAIL: staging minReplicas=$MIN_STG expected 2"; exit 1; }
[ "$MAX_STG" = "4" ] || { echo "FAIL: staging maxReplicas=$MAX_STG expected 4"; exit 1; }
[ "$CPU_STG" = "50" ] || { echo "FAIL: staging CPU target=$CPU_STG expected 50"; exit 1; }

MIN_PROD=$(kubectl -n api-gateway-prod get hpa api-gateway -o jsonpath='{.spec.minReplicas}')
MAX_PROD=$(kubectl -n api-gateway-prod get hpa api-gateway -o jsonpath='{.spec.maxReplicas}')
CPU_PROD=$(kubectl -n api-gateway-prod get hpa api-gateway -o jsonpath='{.spec.metrics[0].resource.target.averageUtilization}')

[ "$MIN_PROD" = "2" ] || { echo "FAIL: prod minReplicas=$MIN_PROD expected 2"; exit 1; }
[ "$MAX_PROD" = "6" ] || { echo "FAIL: prod maxReplicas=$MAX_PROD expected 6"; exit 1; }
[ "$CPU_PROD" = "50" ] || { echo "FAIL: prod CPU target=$CPU_PROD expected 50"; exit 1; }

echo "SUCCESS: Question 5 passed"
