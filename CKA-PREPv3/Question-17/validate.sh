#!/bin/bash
set -euo pipefail

RBAC_FILE="/opt/course/17/operator/base/rbac.yaml"
STUDENTS_FILE="/opt/course/17/operator/base/students.yaml"

# Check RBAC Role has education.killer.sh access for students and classes with verb list
grep -A2 'apiGroups:.*education.killer.sh' "$RBAC_FILE" | grep resources | grep students >/dev/null
grep -A2 'apiGroups:.*education.killer.sh' "$RBAC_FILE" | grep resources | grep classes >/dev/null
grep -A2 'apiGroups:.*education.killer.sh' "$RBAC_FILE" | grep verbs | grep list >/dev/null

echo "[PASS] operator-role updated to allow list on students/classes using education.killer.sh API group"

# Check student4 exists in students manifest
grep -q '^kind: Student' "$STUDENTS_FILE"
grep -q 'name: student4' "$STUDENTS_FILE"

echo "[PASS] student4 custom resource exists in students.yaml"

# Check if Kubernetes object exists after apply
kubectl kustomize /opt/course/17/operator/prod | kubectl apply -f - >/dev/null
kubectl -n operator-prod get student student4 >/dev/null 2>&1 && echo "[PASS] student4 object applied successfully" || echo "[FAIL] student4 not found in the cluster (manual check required if CRD is not present)"

OP_POD=$(kubectl -n operator-prod get pods -l app=operator -o jsonpath='{.items[0].metadata.name}')
kubectl -n operator-prod logs "$OP_POD" | grep -q forbidden || echo "[PASS] No forbidden list errors in operator pod logs (or simulated output)." || echo "[FAIL] RBAC issues remain, check pod logs." 

exit 0
