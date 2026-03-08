#!/bin/bash
set -euo pipefail

# Validate find_pods.sh exists and contains correct command
if [ ! -f /opt/course/5/find_pods.sh ]; then
  echo "Missing: /opt/course/5/find_pods.sh" >&2
  exit 1
fi
grep -Fxq "kubectl get pods -A --sort-by=.metadata.creationTimestamp" /opt/course/5/find_pods.sh || { echo "Incorrect contents in find_pods.sh" >&2; exit 1; }

# Validate find_pods_uid.sh exists and contains correct command
if [ ! -f /opt/course/5/find_pods_uid.sh ]; then
  echo "Missing: /opt/course/5/find_pods_uid.sh" >&2
  exit 1
fi
grep -Fxq "kubectl get pods -A --sort-by=.metadata.uid" /opt/course/5/find_pods_uid.sh || { echo "Incorrect contents in find_pods_uid.sh" >&2; exit 1; }

echo 'Validation successful!'
