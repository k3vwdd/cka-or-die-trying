#!/bin/bash
set -euo pipefail

MAN=/etc/kubernetes/manifests/controlplane-probe.yaml
[ -f "$MAN" ] || { echo "FAIL: manifest missing"; exit 1; }

kubectl get pod controlplane-probe -n default >/dev/null 2>&1 || { echo "FAIL: pod missing"; exit 1; }
PHASE=$(kubectl get pod controlplane-probe -n default -o jsonpath='{.status.phase}')
[ "$PHASE" = "Running" ] || { echo "FAIL: pod not running"; exit 1; }

echo "PASS: Question 4"
