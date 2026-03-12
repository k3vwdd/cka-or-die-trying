#!/bin/bash
set -e

kubectl delete pod cp-only -n default --ignore-not-found

echo "Question 14 setup complete"
