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

kubectl apply -f - <<'EOF'
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: tenants.minio.min.io
spec:
  group: minio.min.io
  names:
    kind: Tenant
    listKind: TenantList
    plural: tenants
    singular: tenant
  scope: Namespaced
  versions:
  - name: v2
    served: true
    storage: true
    schema:
      openAPIV3Schema:
        type: object
        x-kubernetes-preserve-unknown-fields: true
EOF

kubectl delete ns minio --ignore-not-found >/dev/null 2>&1 || true

echo "Question 2 environment ready at /opt/course/2"
