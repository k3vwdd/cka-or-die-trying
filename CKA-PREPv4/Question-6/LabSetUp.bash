#!/bin/bash
set -e

kubectl create ns qv4-06 --dry-run=client -o yaml | kubectl apply -f -
kubectl -n qv4-06 delete deploy web --ignore-not-found

cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
  namespace: qv4-06
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: web
        image: nginx:1-alpine
        command: ["sh","-c","exit 1"]
EOF

echo "Question 6 setup complete"
