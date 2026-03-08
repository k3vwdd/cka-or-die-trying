# 1. Inspect operator pod logs to find out which resources are forbidden (forbidden errors)
kubectl -n operator-prod get pods
OP_POD=$(kubectl -n operator-prod get pods -l app=operator -o jsonpath='{.items[0].metadata.name}')
kubectl -n operator-prod logs "$OP_POD"

# 2. Update the base RBAC role to allow listing the required CRDs (e.g. students, classes)
# Edit: /opt/course/17/operator/base/rbac.yaml
# Add a rule like:
# - apiGroups: ["education.killer.sh"]
#   resources: ["students", "classes"]
#   verbs: ["list"]

# 3. Add student4 to the base students manifest
# Edit: /opt/course/17/operator/base/students.yaml
# Add:
# ---
# apiVersion: education.killer.sh/v1
# kind: Student
# metadata:
#   name: student4
# spec:
#   name: Any Name
#   description: Any Description

# 4. Deploy the updated prod Kustomize overlay
kubectl kustomize /opt/course/17/operator/prod | kubectl apply -f -

# 5. Confirm no RBAC errors and student4 exists in the cluster
kubectl -n operator-prod logs "$OP_POD"
kubectl -n operator-prod get students || echo 'Student CRD check - manual if not supported by mock'
