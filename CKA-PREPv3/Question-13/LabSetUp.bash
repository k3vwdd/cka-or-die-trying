#!/bin/bash
set -e

# Clean up potential pre-existing pod
target_pod=multi-container-playground
kubectl delete pod $target_pod --ignore-not-found --namespace=default
