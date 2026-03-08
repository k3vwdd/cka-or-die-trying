#!/bin/bash
set -euo pipefail

# 1. Ensure namespace exists
test "$(kubectl get ns secret --no-headers | awk '{print $1}')" = "secret"

# 2. Check if secret1 exists in the namespace
kubectl -n secret get secret secret1

# 3. Check if secret2 exists and has correct data
data_user=$(kubectl -n secret get secret secret2 -o jsonpath='{.data.user}')
data_pass=$(kubectl -n secret get secret secret2 -o jsonpath='{.data.pass}')
[ "$(echo "$data_user" | base64 -d)" = "user1" ]
[ "$(echo "$data_pass" | base64 -d)" = "1234" ]

# 4. Ensure the pod is running
kubectl -n secret get pod secret-pod -o jsonpath='{.status.phase}' | grep -q Running

# 5. Verify env vars are present in pod
env_actual=$(kubectl -n secret exec secret-pod -- sh -c 'echo $APP_USER:$APP_PASS')
[ "$env_actual" = "user1:1234" ]

# 6. Verify secret1 is mounted
kubectl -n secret exec secret-pod -- ls /tmp/secret1 | grep -q "."

# 7. Check that mount is read-only (write attempt should fail)
set +e
kubectl -n secret exec secret-pod -- sh -c "touch /tmp/secret1/should_fail" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "FAIL: secret1 volume at /tmp/secret1 is not read-only"
    exit 1
fi
set -e

echo "Validation passed!"
