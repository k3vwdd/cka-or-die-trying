#!/bin/bash
set -e

mkdir -p /opt/course/2

cat > /opt/course/2/minio-tenant.yaml <<'EOF'
apiVersion: minio.min.io/v2
kind: Tenant
metadata:
  name: tenant-lite
  namespace: minio
spec:
  image: quay.io/minio/minio:RELEASE.2024-01-18T22-51-28Z
  pools:
  - servers: 1
    volumesPerServer: 1
    size: 1Gi
  features:
    enableSFTP: false
EOF

kubectl delete ns minio --ignore-not-found >/dev/null 2>&1 || true
kubectl delete crd tenants.minio.min.io miniojobs.job.min.io policybindings.sts.min.io --ignore-not-found >/dev/null 2>&1 || true

echo "Question 2 environment ready at /opt/course/2"
