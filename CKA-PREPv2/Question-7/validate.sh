#!/bin/bash
set -euo pipefail

echo "Validating Question 7..."

[ -f /opt/course/7/node.sh ] || { echo "FAIL: /opt/course/7/node.sh missing"; exit 1; }
[ -f /opt/course/7/pod.sh ] || { echo "FAIL: /opt/course/7/pod.sh missing"; exit 1; }
[ -x /opt/course/7/node.sh ] || { echo "FAIL: /opt/course/7/node.sh not executable"; exit 1; }
[ -x /opt/course/7/pod.sh ] || { echo "FAIL: /opt/course/7/pod.sh not executable"; exit 1; }

grep -Eq '^kubectl top node[[:space:]]*$' /opt/course/7/node.sh || { echo "FAIL: node.sh command incorrect"; exit 1; }
grep -Eq '^kubectl top pod --containers=true[[:space:]]*$' /opt/course/7/pod.sh || { echo "FAIL: pod.sh command incorrect"; exit 1; }

[ "$(wc -l < /opt/course/7/node.sh | tr -d ' ')" = "1" ] || { echo "FAIL: node.sh should contain exactly one command"; exit 1; }
[ "$(wc -l < /opt/course/7/pod.sh | tr -d ' ')" = "1" ] || { echo "FAIL: pod.sh should contain exactly one command"; exit 1; }

echo "SUCCESS: Question 7 passed"
