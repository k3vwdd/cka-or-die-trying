#!/bin/bash
set -e

mkdir -p /opt/course/p2
kubectl create ns project-hamster --dry-run=client -o yaml | kubectl apply -f -

kubectl -n project-hamster delete svc p2-service --ignore-not-found >/dev/null 2>&1 || true
kubectl -n project-hamster delete pod p2-pod --ignore-not-found >/dev/null 2>&1 || true

rm -f /opt/course/p2/iptables.txt

echo "Preview Question 2 environment ready at /opt/course/p2"
