#!/bin/bash
set -e

kubectl create ns qv4-08 --dry-run=client -o yaml | kubectl apply -f -
kubectl -n qv4-08 delete deploy checkout --ignore-not-found

cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: checkout
  namespace: qv4-08
spec:
  replicas: 1
  selector:
    matchLabels:
      app: checkout
  template:
    metadata:
      labels:
        app: checkout
    spec:
      containers:
      - name: app
        image: nginx:1-alpinex
EOF

echo "Question 8 setup complete"
