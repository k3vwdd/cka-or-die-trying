#!/bin/bash
set -euo pipefail

NS="secret"
POD="secret-pod"
EXPECTED_IMAGE="busybox:1"
MOUNT_PATH="/tmp/secret1"

fail() {
  echo "FAIL: $1"
  exit 1
}

pass() {
  echo "PASS: $1"
}

kubectl get namespace "$NS" >/dev/null 2>&1 || fail "Namespace $NS does not exist"
pass "Namespace $NS exists"

kubectl -n "$NS" get pod "$POD" >/dev/null 2>&1 || fail "Pod $POD does not exist in namespace $NS"
pass "Pod $POD exists"

phase=$(kubectl -n "$NS" get pod "$POD" -o jsonpath='{.status.phase}')
[ "$phase" = "Running" ] || fail "Pod $POD is not Running, current phase: $phase"
pass "Pod $POD is Running"

image=$(kubectl -n "$NS" get pod "$POD" -o jsonpath='{.spec.containers[0].image}')
[ "$image" = "$EXPECTED_IMAGE" ] || fail "Pod image is $image, expected $EXPECTED_IMAGE"
pass "Pod image is $EXPECTED_IMAGE"

kubectl -n "$NS" get secret secret2 >/dev/null 2>&1 || fail "Secret secret2 does not exist"
pass "Secret secret2 exists"

user_val=$(kubectl -n "$NS" get secret secret2 -o jsonpath='{.data.user}' | base64 -d)
pass_val=$(kubectl -n "$NS" get secret secret2 -o jsonpath='{.data.pass}' | base64 -d)
[ "$user_val" = "user1" ] || fail "secret2 key user is '$user_val', expected 'user1'"
[ "$pass_val" = "1234" ] || fail "secret2 key pass is '$pass_val', expected '1234'"
pass "Secret secret2 contains expected keys and values"

secret1_name=$(kubectl -n "$NS" get -f /opt/course/11/secret1.yaml -o jsonpath='{.metadata.name}' 2>/dev/null || true)
[ -n "$secret1_name" ] || fail "Could not determine secret name from /opt/course/11/secret1.yaml"

kubectl -n "$NS" get secret "$secret1_name" >/dev/null 2>&1 || fail "Secret from /opt/course/11/secret1.yaml was not created in namespace $NS"
pass "Secret $secret1_name from provided manifest exists"

vol_secret_name=$(kubectl -n "$NS" get pod "$POD" -o jsonpath='{range .spec.volumes[*]}{.name}:{.secret.secretName}{"\n"}{end}' | awk -F: -v s="$secret1_name" '$2==s{print $2}' | head -n1)
[ "$vol_secret_name" = "$secret1_name" ] || fail "Pod does not define a volume using Secret $secret1_name"
pass "Pod defines a Secret volume for $secret1_name"

mount_readonly=$(kubectl -n "$NS" get pod "$POD" -o jsonpath='{range .spec.containers[0].volumeMounts[*]}{.mountPath}:{.readOnly}{"\n"}{end}' | awk -F: -v p="$MOUNT_PATH" '$1==p{print $2}' | head -n1)
[ "$mount_readonly" = "true" ] || fail "Mount path $MOUNT_PATH is missing or not readOnly=true"
pass "Secret volume is mounted at $MOUNT_PATH as read-only"

env_user_secret=$(kubectl -n "$NS" get pod "$POD" -o jsonpath='{range .spec.containers[0].env[*]}{.name}:{.valueFrom.secretKeyRef.name}:{.valueFrom.secretKeyRef.key}{"\n"}{end}' | awk -F: '$1=="APP_USER"{print $2":"$3}' | head -n1)
env_pass_secret=$(kubectl -n "$NS" get pod "$POD" -o jsonpath='{range .spec.containers[0].env[*]}{.name}:{.valueFrom.secretKeyRef.name}:{.valueFrom.secretKeyRef.key}{"\n"}{end}' | awk -F: '$1=="APP_PASS"{print $2":"$3}' | head -n1)
[ "$env_user_secret" = "secret2:user" ] || fail "APP_USER is not sourced from secret2 key user"
[ "$env_pass_secret" = "secret2:pass" ] || fail "APP_PASS is not sourced from secret2 key pass"
pass "Environment variables APP_USER and APP_PASS are sourced from secret2"

exec_user=$(kubectl -n "$NS" exec "$POD" -- printenv APP_USER)
exec_pass=$(kubectl -n "$NS" exec "$POD" -- printenv APP_PASS)
[ "$exec_user" = "user1" ] || fail "Container APP_USER is '$exec_user', expected 'user1'"
[ "$exec_pass" = "1234" ] || fail "Container APP_PASS is '$exec_pass', expected '1234'"
pass "Container environment variables resolve to expected values"

kubectl -n "$NS" exec "$POD" -- test -d "$MOUNT_PATH" || fail "Mount path $MOUNT_PATH does not exist inside container"
pass "Mount path exists inside container"

manifest_keys=$(kubectl get -f /opt/course/11/secret1.yaml -o jsonpath='{range .data[*]}{.}{"\n"}{end}' 2>/dev/null || true)
manifest_string_keys=$(kubectl get -f /opt/course/11/secret1.yaml -o jsonpath='{range .stringData[*]}{.}{"\n"}{end}' 2>/dev/null || true)
secret_keys=$(kubectl -n "$NS" get secret "$secret1_name" -o jsonpath='{range $k,$v := .data}{$k}{"\n"}{end}')

if [ -n "$secret_keys" ]; then
  first_key=$(printf '%s
' "$secret_keys" | head -n1)
  kubectl -n "$NS" exec "$POD" -- test -f "$MOUNT_PATH/$first_key" || fail "Expected secret file $MOUNT_PATH/$first_key not found inside container"
  pass "At least one Secret file is mounted inside container"
else
  fail "Secret $secret1_name has no data keys to validate"
fi

echo "All validations passed"
