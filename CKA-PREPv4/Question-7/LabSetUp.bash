#!/bin/bash
set -e

kubectl create ns qv4-07 --dry-run=client -o yaml | kubectl apply -f -
kubectl -n qv4-07 delete pod api --ignore-not-found

cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: api
  namespace: qv4-07
spec:
  nodeSelector:
    disktype: ssd-never-exists
  containers:
  - name: api
    image: nginx:1-alpine
EOF

echo "Question 7 setup complete"
