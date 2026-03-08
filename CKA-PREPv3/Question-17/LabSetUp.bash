#!/bin/bash
set -e

# This lab relies on pre-existing resources and files already present in the environment.
# The following command reflects the current deployment method from the question.
kubectl kustomize /opt/course/17/operator/prod | kubectl apply -f -
