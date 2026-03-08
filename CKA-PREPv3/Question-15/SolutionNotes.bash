# 1. Create a script to list all events sorted by creation timestamp
cat <<'EOF' > /opt/course/15/cluster_events.sh
kubectl get events -A --sort-by=.metadata.creationTimestamp
EOF

# 2. Find and delete the kube-proxy pod
KUBE_PROXY_POD=$(kubectl -n kube-system get pods -l k8s-app=kube-proxy -o jsonpath='{.items[0].metadata.name}')
kubectl -n kube-system delete pod "$KUBE_PROXY_POD"

# 3. Capture events after pod deletion
kubectl get events -A --sort-by=.metadata.creationTimestamp > /opt/course/15/pod_kill.log

# 4. Find the kube-proxy container ID and force-remove it (container runtime)
KUBE_PROXY_CONTAINER_ID=$(crictl ps | awk '/kube-proxy/ {print $1; exit}')
crictl rm --force "$KUBE_PROXY_CONTAINER_ID"

# 5. Capture events after container kill
kubectl get events -A --sort-by=.metadata.creationTimestamp > /opt/course/15/container_kill.log
