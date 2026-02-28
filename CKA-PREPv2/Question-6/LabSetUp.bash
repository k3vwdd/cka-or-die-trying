#!/bin/bash
set -e

kubectl create ns project-t230 --dry-run=client -o yaml | kubectl apply -f -
kubectl delete deploy safari -n project-t230 --ignore-not-found >/dev/null 2>&1 || true
kubectl delete pvc safari-pvc -n project-t230 --ignore-not-found >/dev/null 2>&1 || true
kubectl delete pv safari-pv --ignore-not-found >/dev/null 2>&1 || true

echo "Question 6 environment ready"
