#!/bin/bash
# Inspect current operator logs to find which custom resources are forbidden
kubectl -n operator-prod get pods
OP_POD=$(kubectl -n operator-prod get pods -l app=operator -o jsonpath='{.items[0].metadata.name}')
kubectl -n operator-prod logs "$OP_POD"

# Update the base RBAC role
# File: /opt/course/17/operator/base/rbac.yaml
# Ensure Role operator-role contains rules allowing list on the required CRDs:
# apiGroups: ["education.killer.sh"]
# resources: ["students", "classes"]
# verbs: ["list"]

# Update the base students manifest
# File: /opt/course/17/operator/base/students.yaml
# Add a new Student resource:
# apiVersion: education.killer.sh/v1
# kind: Student
# metadata:
#   name: student4
# spec:
#   name: Any Name
#   description: Any Description

# Deploy the updated prod overlay
kubectl kustomize /opt/course/17/operator/prod | kubectl apply -f -

# Verify the operator no longer reports the RBAC issue and the new resource exists
kubectl -n operator-prod logs "$OP_POD"
kubectl -n operator-prod get students
