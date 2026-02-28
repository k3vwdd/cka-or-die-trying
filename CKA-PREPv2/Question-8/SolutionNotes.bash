# On control plane
kubectl get nodes

# On worker (via ssh from control plane)
# sudo -i
# apt update
# apt install -y kubelet=<CONTROLPLANE_VERSION>-1.1 kubectl=<CONTROLPLANE_VERSION>-1.1
# systemctl restart kubelet

# Back on control plane
kubeadm token create --print-join-command | tee /opt/course/8/join-command

# On worker (as root)
# $(cat /opt/course/8/join-command)

# Verify on control plane
kubectl get nodes
