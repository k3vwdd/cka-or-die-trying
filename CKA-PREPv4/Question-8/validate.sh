#!/bin/bash
set -euo pipefail

READY=$(kubectl -n qv4-08 get deploy checkout -o jsonpath='{.status.readyReplicas}')
[ "${READY:-0}" = "1" ] || { echo "FAIL: checkout not ready"; exit 1; }

IMG=$(kubectl -n qv4-08 get deploy checkout -o jsonpath='{.spec.template.spec.containers[0].image}')
[ "$IMG" = "nginx:1-alpine" ] || { echo "FAIL: image still incorrect"; exit 1; }

echo "PASS: Question 8"
