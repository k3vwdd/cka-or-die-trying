#!/bin/bash
set -e

kubectl create ns qv4-12 --dry-run=client -o yaml | kubectl apply -f -
kubectl -n qv4-12 delete deploy web pod dns-check svc web-internl svc web-internal --ignore-not-found

cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
  namespace: qv4-12
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
---
apiVersion: v1
kind: Service
metadata:
  name: web-internl
  namespace: qv4-12
spec:
  selector:
    app: web
  ports:
  - port: 80
    targetPort: 80
---
apiVersion: v1
kind: Pod
metadata:
  name: dns-check
  namespace: qv4-12
spec:
  containers:
  - name: checker
    image: busybox:1
    command: ["sh","-c","sleep 3600"]
    readinessProbe:
      exec:
        command: ["sh","-c","nslookup web-internal.qv4-12.svc.cluster.local >/dev/null"]
      initialDelaySeconds: 2
      periodSeconds: 3
EOF

echo "Question 12 setup complete"
