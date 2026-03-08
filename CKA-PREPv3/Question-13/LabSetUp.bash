#!/bin/bash
set -e

# Intentionally minimal setup for this task.
# Ensure any old resources from previous attempts do not interfere.
kubectl delete pod multi-container-playground -n default --ignore-not-found=true >/dev/null 2>&1 || true
rm -f /tmp/multi-container-playground.yaml
