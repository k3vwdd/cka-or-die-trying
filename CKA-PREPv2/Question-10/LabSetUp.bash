#!/bin/bash
set -e

kubectl create ns project-hamster --dry-run=client -o yaml | kubectl apply -f -

kubectl -n project-hamster delete rolebinding processor --ignore-not-found >/dev/null 2>&1 || true
kubectl -n project-hamster delete role processor --ignore-not-found >/dev/null 2>&1 || true
kubectl -n project-hamster delete sa processor --ignore-not-found >/dev/null 2>&1 || true

echo "Question 10 environment ready"
