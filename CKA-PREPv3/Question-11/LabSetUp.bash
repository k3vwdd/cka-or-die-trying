#!/bin/bash
set -e

kubectl get namespace secret >/dev/null 2>&1 || kubectl create namespace secret >/dev/null

kubectl -n secret delete pod secret-pod --ignore-not-found >/dev/null 2>&1 || true
kubectl -n secret delete secret secret2 --ignore-not-found >/dev/null 2>&1 || true

if kubectl get secret -n secret >/dev/null 2>&1; then
  if kubectl -n secret get -f /opt/course/11/secret1.yaml >/dev/null 2>&1; then
    secret_name=$(kubectl -n secret get -f /opt/course/11/secret1.yaml -o jsonpath='{.metadata.name}' 2>/dev/null || true)
    if [ -n "${secret_name:-}" ]; then
      kubectl -n secret delete secret "$secret_name" --ignore-not-found >/dev/null 2>&1 || true
    fi
  fi
fi

rm -f /tmp/secret-pod.yaml
