#!/bin/bash
set -e

kubectl create namespace project-h800 --dry-run=client -o yaml | kubectl apply -f -

kubectl -n project-h800 apply -f - <<'EOF'
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: o3db
spec:
  serviceName: o3db
  replicas: 3
  selector:
    matchLabels:
      app: o3db
  template:
    metadata:
      labels:
        app: o3db
    spec:
      containers:
      - name: db
        image: busybox:stable
        command: ["sh", "-c", "sleep 3600"]
EOF

echo "Question 3 environment ready"
