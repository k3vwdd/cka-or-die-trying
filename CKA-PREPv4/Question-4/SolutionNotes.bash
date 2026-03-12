cat <<'EOF' > /etc/kubernetes/manifests/controlplane-probe.yaml
apiVersion: v1
kind: Pod
metadata:
  name: controlplane-probe
  namespace: default
spec:
  containers:
  - name: probe
    image: busybox:1
    command: ["sh","-c","while true; do date >> /logs/probe.log; sleep 5; done"]
    volumeMounts:
    - name: host-logs
      mountPath: /logs
  volumes:
  - name: host-logs
    hostPath:
      path: /opt/course/v4/4/logs
      type: DirectoryOrCreate
EOF

kubectl get pod controlplane-probe -n default
