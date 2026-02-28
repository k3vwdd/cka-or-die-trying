#!/bin/bash
set -e

mkdir -p /opt/course/17
kubectl create ns project-tiger --dry-run=client -o yaml | kubectl apply -f -
kubectl -n project-tiger delete pod tigers-reunite --ignore-not-found >/dev/null 2>&1 || true
rm -f /opt/course/17/pod-container.txt /opt/course/17/pod-container.log

echo "Question 17 environment ready at /opt/course/17"
