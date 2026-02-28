#!/bin/bash
set -euo pipefail

echo "Validating Question 2..."

kubectl get ns minio >/dev/null 2>&1 || { echo "FAIL: namespace minio missing"; exit 1; }

helm -n minio list | grep -q '^minio-operator\b' || { echo "FAIL: helm release minio-operator missing in namespace minio"; exit 1; }

[ -f /opt/course/2/minio-tenant.yaml ] || { echo "FAIL: /opt/course/2/minio-tenant.yaml missing"; exit 1; }
grep -Eq 'enableSFTP:[[:space:]]*true' /opt/course/2/minio-tenant.yaml || { echo "FAIL: enableSFTP true not found in tenant yaml"; exit 1; }

kubectl -n minio get tenant tenant-lite >/dev/null 2>&1 || { echo "FAIL: tenant-lite not applied in minio namespace"; exit 1; }

SFTP_ENABLED=$(kubectl -n minio get tenant tenant-lite -o jsonpath='{.spec.features.enableSFTP}')
[ "$SFTP_ENABLED" = "true" ] || { echo "FAIL: tenant spec.features.enableSFTP is $SFTP_ENABLED expected true"; exit 1; }

echo "SUCCESS: Question 2 passed"
