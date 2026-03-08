#!/bin/bash
set -e

# 1) Ensure target directory exists
mkdir -p /opt/course/5

# 2) Create script for sorting pods by creation timestamp (AGE)
cat <<'EOF' > /opt/course/5/find_pods.sh
kubectl get pods -A --sort-by=.metadata.creationTimestamp
EOF

# 3) Create script for sorting pods by UID
cat <<'EOF' > /opt/course/5/find_pods_uid.sh
kubectl get pods -A --sort-by=.metadata.uid
EOF
