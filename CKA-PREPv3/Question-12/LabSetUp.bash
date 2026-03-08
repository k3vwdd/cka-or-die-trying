#!/bin/bash
set -e

# Ensure a clean starting state for the lab
kubectl delete pod pod1 -n default --ignore-not-found=true
