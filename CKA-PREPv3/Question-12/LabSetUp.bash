#!/bin/bash
set -e

# Clean up any pre-existing resources from previous runs
test -f /tmp/pod1.yaml && rm -f /tmp/pod1.yaml || true
kubectl delete pod pod1 -n default --ignore-not-found
