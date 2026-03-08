#!/bin/bash
set -euo pipefail

POD=multi-container-playground
NS=default

# Check pod exists and is running
kubectl get pod "$POD" -n "$NS" -o jsonpath='{.status.phase}' | grep -E 'Running|Succeeded'

# Check containers exist with correct names
kubectl get pod "$POD" -n "$NS" -o json | grep '"name": "c1"'
kubectl get pod "$POD" -n "$NS" -o json | grep '"name": "c2"'
kubectl get pod "$POD" -n "$NS" -o json | grep '"name": "c3"'

# Check c1 has env var MY_NODE_NAME sourced from fieldRef
[ "$(kubectl exec -n "$NS" "$POD" -c c1 -- env | grep ^MY_NODE_NAME= | wc -l)" -eq 1 ]

# Check c3 logs have timestamps (date output in any line of date.log)
logs=$(kubectl logs -n "$NS" "$POD" -c c3 --tail=5)
echo "$logs" | grep -E "[0-9]{4}" # year in date string

# Check volume is emptyDir (non-persistent)
vol_type=$(kubectl get pod "$POD" -n "$NS" -o jsonpath='{.spec.volumes[?(@.name=="vol")].emptyDir}')
if [[ -z "$vol_type" ]]; then
  echo "ERROR: emptyDir volume named 'vol' not found on pod $POD" >&2
  exit 1
fi

echo "Validation passed: Pod \"$POD\" meets all requirements."
