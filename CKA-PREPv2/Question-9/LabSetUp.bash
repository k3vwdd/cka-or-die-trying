#!/bin/bash
set -e

mkdir -p /opt/course/9
kubectl create ns project-swan --dry-run=client -o yaml | kubectl apply -f -

kubectl -n project-swan create sa secret-reader --dry-run=client -o yaml | kubectl apply -f -

kubectl -n project-swan apply -f - <<'EOF'
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: secret-reader
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: secret-reader
subjects:
- kind: ServiceAccount
  name: secret-reader
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: secret-reader
EOF

kubectl -n project-swan create secret generic swan-demo --from-literal=key=value --dry-run=client -o yaml | kubectl apply -f -

kubectl -n project-swan delete pod api-contact --ignore-not-found >/dev/null 2>&1 || true
rm -f /opt/course/9/result.json

echo "Question 9 environment ready at /opt/course/9"
