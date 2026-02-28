#!/bin/bash
set -euo pipefail

echo "Validating Question 4..."

[ -f /opt/course/4/pods-terminated-first.txt ] || { echo "FAIL: output file missing"; exit 1; }

EXPECTED=$(sort /opt/course/4/expected.txt)
ACTUAL=$(sort /opt/course/4/pods-terminated-first.txt)

[ "$EXPECTED" = "$ACTUAL" ] || { echo "FAIL: pod list does not match BestEffort pods"; exit 1; }

while IFS= read -r pod; do
  [ -n "$pod" ] || continue
  kubectl -n project-c13 get pod "$pod" >/dev/null 2>&1 || { echo "FAIL: listed pod $pod does not exist"; exit 1; }
  QOS=$(kubectl -n project-c13 get pod "$pod" -o jsonpath='{.status.qosClass}')
  [ "$QOS" = "BestEffort" ] || { echo "FAIL: listed pod $pod has qos=$QOS expected BestEffort"; exit 1; }
done < /opt/course/4/pods-terminated-first.txt

echo "SUCCESS: Question 4 passed"
