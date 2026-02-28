#!/bin/bash
set -euo pipefail

echo "Validating Question 9..."

kubectl -n project-swan get pod api-contact >/dev/null 2>&1 || { echo "FAIL: pod api-contact missing"; exit 1; }
SA=$(kubectl -n project-swan get pod api-contact -o jsonpath='{.spec.serviceAccountName}')
IMG=$(kubectl -n project-swan get pod api-contact -o jsonpath='{.spec.containers[0].image}')
[ "$SA" = "secret-reader" ] || { echo "FAIL: pod serviceAccountName is $SA expected secret-reader"; exit 1; }
[ "$IMG" = "nginx:1-alpine" ] || { echo "FAIL: pod image is $IMG expected nginx:1-alpine"; exit 1; }

[ -f /opt/course/9/result.json ] || { echo "FAIL: /opt/course/9/result.json missing"; exit 1; }

grep -q '"kind":"SecretList"\|"kind": "SecretList"' /opt/course/9/result.json || { echo "FAIL: result does not appear to be secrets API response"; exit 1; }
grep -q '"apiVersion":"v1"\|"apiVersion": "v1"' /opt/course/9/result.json || { echo "FAIL: result missing apiVersion v1"; exit 1; }
grep -q '"items":' /opt/course/9/result.json || { echo "FAIL: result missing items field"; exit 1; }

echo "SUCCESS: Question 9 passed"
