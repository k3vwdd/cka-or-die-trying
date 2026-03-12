#!/bin/bash
set -euo pipefail

READY=$(kubectl -n qv4-09 get deploy payments -o jsonpath='{.status.readyReplicas}')
[ "${READY:-0}" = "1" ] || { echo "FAIL: payments not ready"; exit 1; }

PATH_OK=$(kubectl -n qv4-09 get deploy payments -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.httpGet.path}')
[ "$PATH_OK" = "/" ] || { echo "FAIL: readiness path not fixed"; exit 1; }

echo "PASS: Question 9"
