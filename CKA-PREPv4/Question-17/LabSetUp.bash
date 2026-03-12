#!/bin/bash
set -e

kubectl create ns qv4-17 --dry-run=client -o yaml | kubectl apply -f -
kubectl -n qv4-17 delete deploy app svc app-svc pod tester pod intruder netpol deny-all netpol allow-tester --ignore-not-found

cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app
  namespace: qv4-17
spec:
  replicas: 2
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
  namespace: qv4-17
spec:
  selector:
    app: wrong
  ports:
  - port: 80
    targetPort: 80
---
apiVersion: v1
kind: Pod
metadata:
  name: tester
  namespace: qv4-17
  labels:
    role: tester
spec:
  containers:
  - name: curl
    image: curlimages/curl:8.11.0
    command: ["sh","-c","sleep 3600"]
---
apiVersion: v1
kind: Pod
metadata:
  name: intruder
  namespace: qv4-17
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
  namespace: qv4-17
spec:
  podSelector:
    matchLabels:
      app: app
  policyTypes: ["Ingress"]
EOF

echo "Question 17 setup complete"
