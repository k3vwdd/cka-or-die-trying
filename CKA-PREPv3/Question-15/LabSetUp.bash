#!/bin/bash
set -e

mkdir -p /opt/course/15

cat <<'EOF' > /opt/course/15/cluster_events.sh
kubectl get events -A --sort-by=.metadata.creationTimestamp
EOF
chmod +x /opt/course/15/cluster_events.sh
