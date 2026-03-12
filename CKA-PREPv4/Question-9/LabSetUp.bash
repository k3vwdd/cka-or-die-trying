#!/bin/bash
set -e

kubectl create ns qv4-09 --dry-run=client -o yaml | kubectl apply -f -
kubectl -n qv4-09 delete deploy payments --ignore-not-found

cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: payments
  namespace: qv4-09
spec:
  replicas: 1
  selector:
    matchLabels:
      app: payments
  template:
    metadata:
      labels:
        app: payments
    spec:
      containers:
      - name: app
        image: nginx:1-alpine
        readinessProbe:
          httpGet:
            path: /not-found
            port: 80
          initialDelaySeconds: 2
          periodSeconds: 3
EOF

echo "Question 9 setup complete"
