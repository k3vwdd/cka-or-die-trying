# Creates the target directory if missing
mkdir -p /opt/course/5

# Writes the command to find all pods in all namespaces sorted by age
cat <<'EOF' > /opt/course/5/find_pods.sh
kubectl get pods -A --sort-by=.metadata.creationTimestamp
EOF

# Writes the command to find all pods in all namespaces sorted by UID
cat <<'EOF' > /opt/course/5/find_pods_uid.sh
kubectl get pods -A --sort-by=.metadata.uid
EOF
