#!/bin/bash
set -e

# Create the namespace
kubectl create namespace secret

# Copy secret1.yaml to /opt/course/11/ if not already present (TODO if needed)
# mkdir -p /opt/course/11
# cp /path/to/source/secret1.yaml /opt/course/11/secret1.yaml

# Apply secret1.yaml manifest in the correct namespace
kubectl apply -f /opt/course/11/secret1.yaml -n secret

# Pre-clean secrets and pod for idempotency
kubectl -n secret delete secrets secret2 --ignore-not-found
kubectl -n secret delete pod secret-pod --ignore-not-found

# Create secret2
kubectl -n secret create secret generic secret2 --from-literal=user=user1 --from-literal=pass=1234
