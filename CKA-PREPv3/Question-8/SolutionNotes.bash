mkdir -p /opt/course/8

systemctl status kubelet

ls -1 /etc/kubernetes/manifests

kubectl -n kube-system get pods -o wide

kubectl -n kube-system get deploy,ds

cat <<'EOF' > /opt/course/8/controlplane-components.txt
kubelet: process
kube-apiserver: static-pod
kube-scheduler: static-pod
kube-controller-manager: static-pod
etcd: static-pod
dns: pod coredns
EOF

cat /opt/course/8/controlplane-components.txt
