mkdir -p /opt/course/v4/15

cat <<'EOF' > /opt/course/v4/15/cluster_events.sh
kubectl get events -A --sort-by=.metadata.creationTimestamp
EOF

kubectl -n qv4-15 delete pod event-target
kubectl get events -A --sort-by=.metadata.creationTimestamp > /opt/course/v4/15/pod-delete.log

kubectl -n qv4-15 run event-target --image=nginx:1-alpine --restart=Never
sleep 5
CID=$(crictl ps | awk '/event-target/ {print $1; exit}')
crictl rm --force "$CID"
kubectl get events -A --sort-by=.metadata.creationTimestamp > /opt/course/v4/15/container-kill.log
