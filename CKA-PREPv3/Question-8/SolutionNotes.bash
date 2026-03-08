# 1. Ensure output directory exists
mkdir -p /opt/course/8

# 2. To identify kubelet startup type:
systemctl status kubelet
# If kubelet is running as a system service, it is a 'process'

# 3. Check static pod manifests for controlplane components
ls -1 /etc/kubernetes/manifests
# Presence of kube-apiserver.yaml, kube-scheduler.yaml, kube-controller-manager.yaml, etcd.yaml means these run as static-pod

# 4. Confirm running controlplane pods
kubectl -n kube-system get pods -o wide

# 5. Identify DNS application name and workload type
kubectl -n kube-system get deploy,ds
# If DNS is coredns and runs as pods managed by Deployment, label as: pod coredns

# 6. Write final findings in required format
cat <<'EOF' > /opt/course/8/controlplane-components.txt
kubelet: process
kube-apiserver: static-pod
kube-scheduler: static-pod
kube-controller-manager: static-pod
etcd: static-pod
dns: pod coredns
EOF

# 7. Verify output
cat /opt/course/8/controlplane-components.txt
