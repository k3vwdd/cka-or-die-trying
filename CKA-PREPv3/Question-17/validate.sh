#!/bin/bash
set -euo pipefail

BASE_DIR="/opt/course/17/operator/base"
RBAC_FILE="$BASE_DIR/rbac.yaml"
STUDENTS_FILE="$BASE_DIR/students.yaml"

if [ ! -f "$RBAC_FILE" ]; then
  echo "FAIL: Missing file $RBAC_FILE"
  exit 1
fi

if [ ! -f "$STUDENTS_FILE" ]; then
  echo "FAIL: Missing file $STUDENTS_FILE"
  exit 1
fi

# Validate Role operator-role has permissions for both students and classes with verb list
python3 - <<'PY'
import sys, yaml
rbac_file = "/opt/course/17/operator/base/rbac.yaml"
found_role = False
has_required_rule = False

with open(rbac_file, 'r') as f:
    docs = list(yaml.safe_load_all(f))

for doc in docs:
    if not isinstance(doc, dict):
        continue
    if doc.get('kind') == 'Role' and doc.get('metadata', {}).get('name') == 'operator-role':
        found_role = True
        for rule in doc.get('rules', []) or []:
            api_groups = rule.get('apiGroups', []) or []
            resources = rule.get('resources', []) or []
            verbs = rule.get('verbs', []) or []
            if 'education.killer.sh' in api_groups and 'list' in verbs and 'students' in resources and 'classes' in resources:
                has_required_rule = True
                break

if not found_role:
    print('FAIL: Role operator-role not found in base/rbac.yaml')
    sys.exit(1)
if not has_required_rule:
    print('FAIL: Role operator-role does not grant list on students and classes in apiGroup education.killer.sh')
    sys.exit(1)
print('PASS: RBAC manifest contains required permissions')
PY

# Validate student4 manifest exists in base students file
python3 - <<'PY'
import sys, yaml
students_file = "/opt/course/17/operator/base/students.yaml"
found = False
with open(students_file, 'r') as f:
    docs = list(yaml.safe_load_all(f))
for doc in docs:
    if not isinstance(doc, dict):
        continue
    if doc.get('kind') == 'Student' and doc.get('apiVersion') == 'education.killer.sh/v1' and doc.get('metadata', {}).get('name') == 'student4':
        spec = doc.get('spec', {}) or {}
        if 'name' in spec and 'description' in spec:
            found = True
            break
if not found:
    print('FAIL: Student resource student4 with spec.name and spec.description not found in base/students.yaml')
    sys.exit(1)
print('PASS: student4 manifest exists in base/students.yaml')
PY

# Validate applied cluster Role permissions
if ! kubectl -n operator-prod get role operator-role >/dev/null 2>&1; then
  echo "FAIL: Role operator-role not found in namespace operator-prod"
  exit 1
fi

ROLE_JSON=$(kubectl -n operator-prod get role operator-role -o json)
export ROLE_JSON
python3 - <<'PY'
import json, os, sys
role = json.loads(os.environ['ROLE_JSON'])
rules = role.get('rules', []) or []
for rule in rules:
    api_groups = rule.get('apiGroups', []) or []
    resources = rule.get('resources', []) or []
    verbs = rule.get('verbs', []) or []
    if 'education.killer.sh' in api_groups and 'list' in verbs and 'students' in resources and 'classes' in resources:
        print('PASS: Applied Role contains required permissions')
        sys.exit(0)
print('FAIL: Applied Role operator-role does not contain required permissions')
sys.exit(1)
PY

# Validate student4 exists in cluster
if ! kubectl -n operator-prod get student student4 >/dev/null 2>&1; then
  echo "FAIL: student4 custom resource not found in namespace operator-prod"
  exit 1
fi

echo "PASS: student4 custom resource exists"

# Validate operator logs do not show forbidden errors for students/classes list
OP_POD=$(kubectl -n operator-prod get pods -l app=operator -o jsonpath='{.items[0].metadata.name}')
if [ -z "$OP_POD" ]; then
  echo "FAIL: Could not determine operator pod"
  exit 1
fi

LOGS=$(kubectl -n operator-prod logs "$OP_POD" 2>/dev/null || true)
if echo "$LOGS" | grep -E 'forbidden|cannot list resource|is forbidden' | grep -E 'students|classes' >/dev/null 2>&1; then
  echo "FAIL: Operator logs still show forbidden errors related to students/classes"
  exit 1
fi

echo "PASS: Operator logs do not show forbidden errors for required CRDs"
echo "All validations passed"
