mkdir -p /opt/course/5

cat <<'EOF' > /opt/course/5/find_pods.sh
kubectl get pods -A --sort-by=.metadata.creationTimestamp
EOF

cat <<'EOF' > /opt/course/5/find_pods_uid.sh
kubectl get pods -A --sort-by=.metadata.uid
EOF

cat /opt/course/5/find_pods.sh
cat /opt/course/5/find_pods_uid.sh

sh /opt/course/5/find_pods.sh
sh /opt/course/5/find_pods_uid.sh
