#!/bin/bash
set -euo pipefail

echo "Validating Question 17..."

NS=project-tiger
POD=tigers-reunite

kubectl -n "$NS" get pod "$POD" >/dev/null 2>&1 || { echo "FAIL: pod tigers-reunite missing"; exit 1; }

LBL1=$(kubectl -n "$NS" get pod "$POD" -o jsonpath='{.metadata.labels.pod}')
LBL2=$(kubectl -n "$NS" get pod "$POD" -o jsonpath='{.metadata.labels.container}')
IMG=$(kubectl -n "$NS" get pod "$POD" -o jsonpath='{.spec.containers[0].image}')
[ "$LBL1" = "container" ] || { echo "FAIL: label pod=container missing"; exit 1; }
[ "$LBL2" = "pod" ] || { echo "FAIL: label container=pod missing"; exit 1; }
[ "$IMG" = "httpd:2-alpine" ] || { echo "FAIL: image must be httpd:2-alpine"; exit 1; }

[ -f /opt/course/17/pod-container.txt ] || { echo "FAIL: pod-container.txt missing"; exit 1; }
[ -f /opt/course/17/pod-container.log ] || { echo "FAIL: pod-container.log missing"; exit 1; }

EXPECTED_RAW=$(kubectl -n "$NS" get pod "$POD" -o jsonpath='{.status.containerStatuses[0].containerID}')
EXPECTED_ID=${EXPECTED_RAW#*://}

FILE_ID=$(awk '{print $1}' /opt/course/17/pod-container.txt)
FILE_RT=$(awk '{print $2}' /opt/course/17/pod-container.txt)
FIELD_COUNT=$(awk '{print NF}' /opt/course/17/pod-container.txt)

[ "$FILE_ID" = "$EXPECTED_ID" ] || { echo "FAIL: container ID in pod-container.txt is incorrect"; exit 1; }
[ -n "$FILE_RT" ] || { echo "FAIL: runtimeType missing in pod-container.txt"; exit 1; }
[ "$FILE_RT" != "unknown" ] || { echo "FAIL: runtimeType cannot be 'unknown'"; exit 1; }
[ "$FILE_RT" != "container-runtime" ] || { echo "FAIL: runtimeType cannot be placeholder text"; exit 1; }
[ "$FIELD_COUNT" = "2" ] || { echo "FAIL: pod-container.txt must contain exactly two fields"; exit 1; }

[ -s /opt/course/17/pod-container.log ] || { echo "FAIL: pod-container.log is empty"; exit 1; }
grep -Eq 'Apache|AH00|httpd' /opt/course/17/pod-container.log || { echo "FAIL: pod-container.log does not look like httpd container logs"; exit 1; }

echo "SUCCESS: Question 17 passed"
