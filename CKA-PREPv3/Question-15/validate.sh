#!/bin/bash
set -euo pipefail

dir="/opt/course/15"

# 1. Check if cluster_events.sh exists and contains correct command
grep -q 'kubectl get events -A --sort-by=.metadata.creationTimestamp' "$dir/cluster_events.sh"

# 2. Check if pod_kill.log exists and is not empty
if [ ! -s "$dir/pod_kill.log" ]; then
  echo "pod_kill.log missing or empty"
  exit 1
fi

# 3. Check if container_kill.log exists and is not empty
if [ ! -s "$dir/container_kill.log" ]; then
  echo "container_kill.log missing or empty"
  exit 1
fi

echo "Validation succeeded: All expected files present and non-empty."
