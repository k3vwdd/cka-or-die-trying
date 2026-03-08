#!/bin/bash
set -euo pipefail

# Validate that the two Pods exist
kubectl get pod ready-if-service-ready -n default 1>/dev/null
kubectl get pod am-i-ready -n default 1>/dev/null

# Validate the main Pod has a liveness and readiness probe
if ! kubectl get pod ready-if-service-ready -o jsonpath='{.spec.containers[0].livenessProbe.exec.command[0]}' -n default | grep -q true; then
  echo "ERROR: Missing or wrong livenessProbe in ready-if-service-ready"
  exit 1
fi
if ! kubectl get pod ready-if-service-ready -o jsonpath='{.spec.containers[0].readinessProbe.exec.command[2]}' -n default | grep -q 'wget -T2 -O- http://service-am-i-ready:80'; then
  echo "ERROR: Missing or wrong readinessProbe in ready-if-service-ready"
  exit 1
fi

# Check the second Pod's label
if ! kubectl get pod am-i-ready -n default --show-labels | grep -q 'id=cross-server-ready'; then
  echo "ERROR: am-i-ready Pod does not have label id=cross-server-ready"
  exit 1
fi

# Ensure the service exists
if ! kubectl get svc service-am-i-ready -n default &>/dev/null; then
  echo "ERROR: service-am-i-ready Service is missing"
  exit 1
fi

# Wait for the 'ready-if-service-ready' Pod to be Ready (up to 40s)
for i in {1..40}; do
  READY_STATUS=$(kubectl get pod ready-if-service-ready -n default -o=jsonpath='{.status.conditions[?(@.type=="Ready")].status}')
  if [[ "$READY_STATUS" == "True" ]]; then
    exit 0
  fi
  sleep 1
done
echo "ERROR: ready-if-service-ready Pod did not become Ready in 40 seconds"
exit 1
