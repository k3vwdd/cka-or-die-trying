#!/bin/bash
# Question 17 | Operator, CRDs, RBAC, Kustomize

# Kustomize config exists at /opt/course/17/operator and is deployed via:
# kubectl kustomize /opt/course/17/operator/prod | kubectl apply -f -

# Update the Kustomize base config so that:
# 1. Operator Role operator-role has permission to list required CRDs.
#    Determine the required CRDs from the operator logs.
# 2. Add a new Student resource named student4 with any name and description.
# 3. Deploy the updated Kustomize config to prod.

# You should work with the existing manifests under:
# /opt/course/17/operator

# Expected outcome:
# - The Role operator-role allows listing the CRDs required by the operator
# - A new Student custom resource named student4 exists
# - The updated prod overlay is applied successfully

# Useful verification commands:
# kubectl -n operator-prod get pods
# kubectl -n operator-prod logs <operator-pod-name>
# kubectl -n operator-prod get students
