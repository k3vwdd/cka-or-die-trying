#!/bin/bash
set -euo pipefail

echo "Validating Question 10..."

kubectl -n project-hamster get sa processor >/dev/null 2>&1 || { echo "FAIL: SA processor missing"; exit 1; }
kubectl -n project-hamster get role processor >/dev/null 2>&1 || { echo "FAIL: Role processor missing"; exit 1; }
kubectl -n project-hamster get rolebinding processor >/dev/null 2>&1 || { echo "FAIL: RoleBinding processor missing"; exit 1; }

CAN_SECRET=$(kubectl -n project-hamster auth can-i create secrets --as system:serviceaccount:project-hamster:processor)
CAN_CM=$(kubectl -n project-hamster auth can-i create configmaps --as system:serviceaccount:project-hamster:processor)
CAN_DELETE_SECRET=$(kubectl -n project-hamster auth can-i delete secrets --as system:serviceaccount:project-hamster:processor)
CAN_GET_CM=$(kubectl -n project-hamster auth can-i get configmaps --as system:serviceaccount:project-hamster:processor)

[ "$CAN_SECRET" = "yes" ] || { echo "FAIL: service account cannot create secrets"; exit 1; }
[ "$CAN_CM" = "yes" ] || { echo "FAIL: service account cannot create configmaps"; exit 1; }
[ "$CAN_DELETE_SECRET" = "no" ] || { echo "FAIL: service account must not be able to delete secrets"; exit 1; }
[ "$CAN_GET_CM" = "no" ] || { echo "FAIL: service account must not be able to get configmaps"; exit 1; }

ROLE_REF_KIND=$(kubectl -n project-hamster get rolebinding processor -o jsonpath='{.roleRef.kind}')
ROLE_REF_NAME=$(kubectl -n project-hamster get rolebinding processor -o jsonpath='{.roleRef.name}')
SUBJECT_NAME=$(kubectl -n project-hamster get rolebinding processor -o jsonpath='{.subjects[0].name}')
SUBJECT_NS=$(kubectl -n project-hamster get rolebinding processor -o jsonpath='{.subjects[0].namespace}')
[ "$ROLE_REF_KIND" = "Role" ] || { echo "FAIL: rolebinding roleRef.kind must be Role"; exit 1; }
[ "$ROLE_REF_NAME" = "processor" ] || { echo "FAIL: rolebinding roleRef.name must be processor"; exit 1; }
[ "$SUBJECT_NAME" = "processor" ] || { echo "FAIL: rolebinding subject name must be processor"; exit 1; }
[ "$SUBJECT_NS" = "project-hamster" ] || { echo "FAIL: rolebinding subject namespace must be project-hamster"; exit 1; }

echo "SUCCESS: Question 10 passed"
