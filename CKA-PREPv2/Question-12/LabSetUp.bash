#!/bin/bash
set -e

kubectl create ns project-tiger --dry-run=client -o yaml | kubectl apply -f -
kubectl -n project-tiger delete deploy deploy-important --ignore-not-found >/dev/null 2>&1 || true

echo "Question 12 environment ready"
