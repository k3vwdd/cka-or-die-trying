# 1. Check cluster nodes (controlplane should show NotReady/unavailable)
kubectl get nodes
# 2. Check kubelet service status
systemctl status kubelet
# 3. Start kubelet and check for errors
systemctl start kubelet
systemctl status kubelet
# 4. Check where the kubelet binary is
whereis kubelet
# 5. Fix ExecStart path in /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf to point to /usr/bin/kubelet
# 6. Reload systemd and restart kubelet
systemctl daemon-reload
systemctl restart kubelet
systemctl status kubelet
# 7. Confirm node is Ready
kubectl get nodes
# 8. Create Pod
kubectl run success --image=nginx:1-alpine -n default
# 9. Verify the Pod
kubectl get pod success -n default -o wide
