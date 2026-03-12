#!/bin/bash
set -e

kubectl create ns qv4-13 --dry-run=client -o yaml | kubectl apply -f -
kubectl -n qv4-13 delete deploy app svc app-svc pod client pod stranger netpol deny-all netpol allow-client --ignore-not-found

cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app
  namespace: qv4-13
spec:
  replicas: 1
  selector:
    matchLabels:
      app: app
  template:
    metadata:
      labels:
        app: app
    spec:
      containers:
      - name: app
        image: nginx:1-alpine
---
apiVersion: v1
kind: Service
metadata:
  name: app-svc
  namespace: qv4-13
spec:
  selector:
    app: app
  ports:
  - port: 80
    targetPort: 80
---
apiVersion: v1
kind: Pod
metadata:
  name: client
  namespace: qv4-13
  labels:
    role: client
spec:
  containers:
  - name: curl
    image: curlimages/curl:8.11.0
    command: ["sh","-c","sleep 3600"]
---
apiVersion: v1
kind: Pod
metadata:
  name: stranger
  namespace: qv4-13
spec:
  containers:
  - name: curl
    image: curlimages/curl:8.11.0
    command: ["sh","-c","sleep 3600"]
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
  namespace: qv4-13
spec:
  podSelector:
    matchLabels:
      app: app
  policyTypes: ["Ingress"]
EOF

echo "Question 13 setup complete"
