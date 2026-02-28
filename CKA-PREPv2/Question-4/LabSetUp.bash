#!/bin/bash
set -e

mkdir -p /opt/course/4
kubectl create namespace project-c13 --dry-run=client -o yaml | kubectl apply -f -

kubectl -n project-c13 apply -f - <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: be-fast
spec:
  containers:
  - name: c
    image: busybox:stable
    command: ["sh", "-c", "sleep 3600"]
---
apiVersion: v1
kind: Pod
metadata:
  name: be-lite
spec:
  containers:
  - name: c
    image: busybox:stable
    command: ["sh", "-c", "sleep 3600"]
---
apiVersion: v1
kind: Pod
metadata:
  name: bursty
spec:
  containers:
  - name: c
    image: busybox:stable
    command: ["sh", "-c", "sleep 3600"]
    resources:
      requests:
        cpu: 50m
---
apiVersion: v1
kind: Pod
metadata:
  name: guaranteed
spec:
  containers:
  - name: c
    image: busybox:stable
    command: ["sh", "-c", "sleep 3600"]
    resources:
      requests:
        cpu: 50m
        memory: 64Mi
      limits:
        cpu: 50m
        memory: 64Mi
EOF

kubectl -n project-c13 wait --for=condition=Ready pod --all --timeout=90s >/dev/null 2>&1 || true

kubectl -n project-c13 get pods -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.status.qosClass}{"\n"}{end}' | awk '$2=="BestEffort"{print $1}' | sort > /opt/course/4/expected.txt
rm -f /opt/course/4/pods-terminated-first.txt

echo "Question 4 environment ready at /opt/course/4"
