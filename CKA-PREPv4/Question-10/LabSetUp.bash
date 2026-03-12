#!/bin/bash
set -e

kubectl create ns qv4-10 --dry-run=client -o yaml | kubectl apply -f -
kubectl -n qv4-10 delete deploy api svc api pod debug --ignore-not-found

cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api
  namespace: qv4-10
spec:
  replicas: 1
  selector:
    matchLabels:
      app: api
  template:
    metadata:
      labels:
        app: api
    spec:
      containers:
      - name: app
        image: nginx:1-alpine
---
apiVersion: v1
kind: Service
metadata:
  name: api
  namespace: qv4-10
spec:
  selector:
    app: api-wrong
  ports:
  - port: 80
    targetPort: 80
---
apiVersion: v1
kind: Pod
metadata:
  name: debug
  namespace: qv4-10
spec:
  containers:
  - name: curl
    image: curlimages/curl:8.11.0
    command: ["sh","-c","sleep 3600"]
EOF

echo "Question 10 setup complete"
