#!/bin/bash
set -euo pipefail

TARGET_FILE="/opt/course/14/cluster-info"

fail() {
  echo "ERROR: $1"
  exit 1
}

[ -f "$TARGET_FILE" ] || fail "Expected file $TARGET_FILE to exist"

LINE_COUNT=$(wc -l < "$TARGET_FILE")
[ "$LINE_COUNT" -eq 5 ] || fail "Expected exactly 5 lines in $TARGET_FILE, got $LINE_COUNT"

LINE1=$(sed -n '1p' "$TARGET_FILE")
LINE2=$(sed -n '2p' "$TARGET_FILE")
LINE3=$(sed -n '3p' "$TARGET_FILE")
LINE4=$(sed -n '4p' "$TARGET_FILE")
LINE5=$(sed -n '5p' "$TARGET_FILE")

[[ "$LINE1" =~ ^1:\  ]] || fail "Line 1 format invalid. Expected: 1: [ANSWER]"
[[ "$LINE2" =~ ^2:\  ]] || fail "Line 2 format invalid. Expected: 2: [ANSWER]"
[[ "$LINE3" =~ ^3:\  ]] || fail "Line 3 format invalid. Expected: 3: [ANSWER]"
[[ "$LINE4" =~ ^4:\  ]] || fail "Line 4 format invalid. Expected: 4: [ANSWER]"
[[ "$LINE5" =~ ^5:\  ]] || fail "Line 5 format invalid. Expected: 5: [ANSWER]"

ANSWER1=${LINE1#1: }
ANSWER2=${LINE2#2: }
ANSWER3=${LINE3#3: }
ANSWER4=${LINE4#4: }
ANSWER5=${LINE5#5: }

[ -n "$ANSWER1" ] || fail "Line 1 answer is empty"
[ -n "$ANSWER2" ] || fail "Line 2 answer is empty"
[ -n "$ANSWER3" ] || fail "Line 3 answer is empty"
[ -n "$ANSWER4" ] || fail "Line 4 answer is empty"
[ -n "$ANSWER5" ] || fail "Line 5 answer is empty"

EXPECTED_CONTROLPLANE_COUNT=$(kubectl get nodes -l node-role.kubernetes.io/control-plane --no-headers 2>/dev/null | wc -l | tr -d ' ')
EXPECTED_TOTAL_NODES=$(kubectl get nodes --no-headers | wc -l | tr -d ' ')
EXPECTED_WORKER_COUNT=$((EXPECTED_TOTAL_NODES - EXPECTED_CONTROLPLANE_COUNT))
EXPECTED_SERVICE_CIDR=$(grep -oP '(?<=--service-cluster-ip-range=)\S+' /etc/kubernetes/manifests/kube-apiserver.yaml)
EXPECTED_CNI_FILE=$(ls /etc/cni/net.d/*.conf /etc/cni/net.d/*.conflist 2>/dev/null | grep -v podman | head -n 1 || true)
EXPECTED_CNI_NAME=$(basename "$EXPECTED_CNI_FILE")
EXPECTED_CONTROLPLANE_NODE=$(kubectl get node -l node-role.kubernetes.io/control-plane -o jsonpath='{.items[0].metadata.name}')
EXPECTED_STATIC_POD_SUFFIX="-${EXPECTED_CONTROLPLANE_NODE}"
EXPECTED_LINE4="${EXPECTED_CNI_NAME}, ${EXPECTED_CNI_FILE}"

[[ "$ANSWER1" =~ ^[0-9]+$ ]] || fail "Line 1 must be a numeric controlplane node count"
[[ "$ANSWER2" =~ ^[0-9]+$ ]] || fail "Line 2 must be a numeric worker node count"

[ "$ANSWER1" = "$EXPECTED_CONTROLPLANE_COUNT" ] || fail "Line 1 incorrect. Expected controlplane count: $EXPECTED_CONTROLPLANE_COUNT"
[ "$ANSWER2" = "$EXPECTED_WORKER_COUNT" ] || fail "Line 2 incorrect. Expected worker count: $EXPECTED_WORKER_COUNT"
[ "$ANSWER3" = "$EXPECTED_SERVICE_CIDR" ] || fail "Line 3 incorrect. Expected Service CIDR: $EXPECTED_SERVICE_CIDR"
[ "$ANSWER4" = "$EXPECTED_LINE4" ] || fail "Line 4 incorrect. Expected CNI plugin and path: $EXPECTED_LINE4"
[ "$ANSWER5" = "$EXPECTED_STATIC_POD_SUFFIX" ] || fail "Line 5 incorrect. Expected static pod suffix: $EXPECTED_STATIC_POD_SUFFIX"

echo "All validations passed"
