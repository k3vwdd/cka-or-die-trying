#!/bin/bash
set -e

kubectl create ns project-snake --dry-run=client -o yaml | kubectl apply -f -

kubectl -n project-snake apply -f - <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: backend-0
  labels:
    app: backend
spec:
  containers:
  - name: c
    image: nginx:stable
---
apiVersion: v1
kind: Pod
metadata:
  name: db1-0
  labels:
    app: db1
spec:
  containers:
  - name: c
    image: nginx:stable
---
apiVersion: v1
kind: Pod
metadata:
  name: db2-0
  labels:
    app: db2
spec:
  containers:
  - name: c
    image: nginx:stable
---
apiVersion: v1
kind: Pod
metadata:
  name: vault-0
  labels:
    app: vault
spec:
  containers:
  - name: c
    image: nginx:stable
EOF

kubectl -n project-snake delete networkpolicy np-backend --ignore-not-found >/dev/null 2>&1 || true

echo "Question 15 environment ready"
