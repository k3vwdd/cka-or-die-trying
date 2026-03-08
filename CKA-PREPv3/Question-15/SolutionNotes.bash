#!/bin/bash
# Ensure target directory exists
mkdir -p /opt/course/15

# Create script for sorted cluster-wide events
cat <<'EOF' > /opt/course/15/cluster_events.sh
kubectl get events -A --sort-by=.metadata.creationTimestamp
EOF
chmod +x /opt/course/15/cluster_events.sh

# Identify and delete kube-proxy pod
KUBE_PROXY_POD=$(kubectl -n kube-system get pods -l k8s-app=kube-proxy -o jsonpath='{.items[0].metadata.name}')
kubectl -n kube-system delete pod "$KUBE_PROXY_POD"

# Capture relevant events after pod deletion
kubectl get events -A --sort-by=.metadata.creationTimestamp > /opt/course/15/pod_kill.log

# Find kube-proxy container ID and force-remove it
KUBE_PROXY_CONTAINER_ID=$(crictl ps | awk '/kube-proxy/ {print $1; exit}')
crictl rm --force "$KUBE_PROXY_CONTAINER_ID"

# Capture relevant events after container kill
kubectl get events -A --sort-by=.metadata.creationTimestamp > /opt/course/15/container_kill.log

# Optional quick checks
sh /opt/course/15/cluster_events.sh
ls -l /opt/course/15/pod_kill.log /opt/course/15/container_kill.log
