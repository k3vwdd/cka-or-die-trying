#!/bin/bash
set -e

kubectl create ns qv4-11 --dry-run=client -o yaml | kubectl apply -f -
kubectl -n qv4-11 delete deploy web svc web-nodeport --ignore-not-found

cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
  namespace: qv4-11
spec:
  replicas: 1
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
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: web-nodeport
  namespace: qv4-11
spec:
  type: NodePort
  selector:
    app: web
  ports:
  - port: 80
    targetPort: 8080
EOF

echo "Question 11 setup complete"
