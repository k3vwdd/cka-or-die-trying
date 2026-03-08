#!/bin/bash
set -euo pipefail

fail() {
  echo "FAIL: $1"
  exit 1
}

pass() {
  echo "PASS: $1"
}

NS="default"
POD="multi-container-playground"

kubectl get pod "$POD" -n "$NS" >/dev/null 2>&1 || fail "Pod $POD not found in namespace $NS"
pass "Pod exists"

phase=$(kubectl get pod "$POD" -n "$NS" -o jsonpath='{.status.phase}')
[ "$phase" = "Running" ] || fail "Pod phase is $phase, expected Running"
pass "Pod is Running"

container_count=$(kubectl get pod "$POD" -n "$NS" -o jsonpath='{range .spec.containers[*]}{.name}{"\n"}{end}' | wc -l | tr -d ' ')
[ "$container_count" = "3" ] || fail "Expected 3 containers, found $container_count"
pass "Pod has 3 containers"

for c in c1 c2 c3; do
  kubectl get pod "$POD" -n "$NS" -o jsonpath='{range .spec.containers[*]}{.name}{"\n"}{end}' | grep -qx "$c" || fail "Container $c not found"
done
pass "Containers c1, c2, c3 exist"

img_c1=$(kubectl get pod "$POD" -n "$NS" -o jsonpath='{.spec.containers[?(@.name=="c1")].image}')
[ "$img_c1" = "nginx:1-alpine" ] || fail "Container c1 image is $img_c1, expected nginx:1-alpine"
pass "Container c1 image correct"

img_c2=$(kubectl get pod "$POD" -n "$NS" -o jsonpath='{.spec.containers[?(@.name=="c2")].image}')
[ "$img_c2" = "busybox:1" ] || fail "Container c2 image is $img_c2, expected busybox:1"
pass "Container c2 image correct"

img_c3=$(kubectl get pod "$POD" -n "$NS" -o jsonpath='{.spec.containers[?(@.name=="c3")].image}')
[ "$img_c3" = "busybox:1" ] || fail "Container c3 image is $img_c3, expected busybox:1"
pass "Container c3 image correct"

vol_type=$(kubectl get pod "$POD" -n "$NS" -o jsonpath='{.spec.volumes[?(@.name=="vol")].emptyDir}')
[ -n "$vol_type" ] || fail "Shared volume vol with emptyDir not found"
pass "emptyDir shared volume exists"

for c in c1 c2 c3; do
  mount_path=$(kubectl get pod "$POD" -n "$NS" -o jsonpath="{.spec.containers[?(@.name=='$c')].volumeMounts[?(@.name=='vol')].mountPath}")
  [ "$mount_path" = "/vol" ] || fail "Container $c does not mount volume vol at /vol"
done
pass "All containers mount /vol"

env_name=$(kubectl get pod "$POD" -n "$NS" -o jsonpath='{.spec.containers[?(@.name=="c1")].env[?(@.name=="MY_NODE_NAME")].name}')
[ "$env_name" = "MY_NODE_NAME" ] || fail "MY_NODE_NAME env var not configured on c1"

env_field=$(kubectl get pod "$POD" -n "$NS" -o jsonpath='{.spec.containers[?(@.name=="c1")].env[?(@.name=="MY_NODE_NAME")].valueFrom.fieldRef.fieldPath}')
[ "$env_field" = "spec.nodeName" ] || fail "MY_NODE_NAME does not reference spec.nodeName"
pass "c1 exposes node name via MY_NODE_NAME"

actual_node=$(kubectl get pod "$POD" -n "$NS" -o jsonpath='{.spec.nodeName}')
[ -n "$actual_node" ] || fail "Pod is not scheduled to a node"
exec_node=$(kubectl exec -n "$NS" "$POD" -c c1 -- printenv MY_NODE_NAME 2>/dev/null | tr -d '\r')
[ "$exec_node" = "$actual_node" ] || fail "MY_NODE_NAME inside c1 is '$exec_node', expected '$actual_node'"
pass "MY_NODE_NAME value inside c1 is correct"

c2_cmd=$(kubectl get pod "$POD" -n "$NS" -o jsonpath='{.spec.containers[?(@.name=="c2")].command[*]}')
echo "$c2_cmd" | grep -q "date >> /vol/date.log" || fail "c2 command does not write date to /vol/date.log"
echo "$c2_cmd" | grep -q "sleep 1" || fail "c2 command does not write every second"
pass "c2 command is correct"

c3_cmd=$(kubectl get pod "$POD" -n "$NS" -o jsonpath='{.spec.containers[?(@.name=="c3")].command[*]}')
echo "$c3_cmd" | grep -q "tail -f /vol/date.log" || fail "c3 command does not stream /vol/date.log"
pass "c3 command is correct"

kubectl wait --for=condition=Ready pod/$POD -n "$NS" --timeout=120s >/dev/null 2>&1 || fail "Pod did not become Ready"
pass "Pod is Ready"

kubectl exec -n "$NS" "$POD" -c c2 -- sh -c 'test -f /vol/date.log' >/dev/null 2>&1 || fail "date.log not found in shared volume"
pass "date.log exists"

line_count=$(kubectl exec -n "$NS" "$POD" -c c2 -- sh -c 'wc -l < /vol/date.log' 2>/dev/null | tr -d ' ')
case "$line_count" in
  '' ) fail "Unable to determine line count for /vol/date.log" ;;
  *[!0-9]* ) fail "Non-numeric line count returned: $line_count" ;;
esac
[ "$line_count" -ge 1 ] || fail "date.log does not contain any lines"
pass "date.log is being written"

logs=$(kubectl logs -n "$NS" "$POD" -c c3 --tail=20 2>/dev/null || true)
[ -n "$logs" ] || fail "No logs found for container c3"

echo "$logs" | grep -Eq '[A-Z][a-z]{2} .* [0-9]{2}:[0-9]{2}:[0-9]{2}|[0-9]{4}' || fail "c3 logs do not appear to contain streamed date output"
pass "c3 logs show streamed date.log content"

echo "All validations passed"
