#!/bin/bash
set -e

# Ensure the operator-prod namespace exists
kubectl get namespace operator-prod 2>/dev/null || kubectl create namespace operator-prod

# Create the base kustomize directory tree if missing
tree -d /opt/course/17/operator || mkdir -p /opt/course/17/operator/{base,prod}

# Create a minimal base RBAC yaml if it doesn't exist
RBAC_YAML=/opt/course/17/operator/base/rbac.yaml
if [ ! -f "$RBAC_YAML" ]; then
cat <<EOF > "$RBAC_YAML"
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: operator-role
  namespace: operator-prod
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
EOF
fi

# Create a minimal students manifest if it doesn't exist
STUDENTS_YAML=/opt/course/17/operator/base/students.yaml
if [ ! -f "$STUDENTS_YAML" ]; then
cat <<EOF > "$STUDENTS_YAML"
apiVersion: education.killer.sh/v1
kind: Student
metadata:
  name: student1
spec:
  name: First Student
  description: Initial student
EOF
fi

# Create a dummy CRD manifest to simulate real CRDs if not present
CRDS_YAML=/opt/course/17/operator/base/crds.yaml
if [ ! -f "$CRDS_YAML" ]; then
cat <<EOF > "$CRDS_YAML"
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: students.education.killer.sh
spec:
  group: education.killer.sh
  versions:
    - name: v1
      served: true
      storage: true
      schema:
        openAPIV3Schema:
          type: object
  names:
    kind: Student
    plural: students
    singular: student
EOF
fi

# Create a minimal kustomization.yaml in base if not exists
KUSTOMIZATION=/opt/course/17/operator/base/kustomization.yaml
if [ ! -f "$KUSTOMIZATION" ]; then
cat <<EOF > "$KUSTOMIZATION"
resources:
- crds.yaml
- rbac.yaml
- students.yaml
EOF
fi

# Set up prod overlay referencing base
PROD_KUSTOMIZATION=/opt/course/17/operator/prod/kustomization.yaml
if [ ! -f "$PROD_KUSTOMIZATION" ]; then
cat <<EOF > "$PROD_KUSTOMIZATION"
bases:
- ../base
EOF
fi

# Deploy the current config to initialize the environment
kubectl kustomize /opt/course/17/operator/prod | kubectl apply -f - || true

# Deploy a dummy operator pod with proper labels for testing
cat <<EOF | kubectl -n operator-prod apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: operator-sa
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: operator
  labels:
    app: operator
spec:
  replicas: 1
  selector:
    matchLabels:
      app: operator
  template:
    metadata:
      labels:
        app: operator
    spec:
      serviceAccountName: operator-sa
      containers:
      - name: operator
        image: busybox
        command: ['sh', '-c', 'while true; do echo "forbidden: students" >&2; sleep 30; done']
EOF

# Bind the role for operator-sa
cat <<EOF | kubectl -n operator-prod apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: operator-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: operator-role
subjects:
- kind: ServiceAccount
  name: operator-sa
EOF

# Wait for operator pod
kubectl -n operator-prod rollout status deployment/operator --timeout=60s
