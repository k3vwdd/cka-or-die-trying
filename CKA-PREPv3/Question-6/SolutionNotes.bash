#!/bin/bash
# Check node status
kubectl get nodes

# Check kubelet service state
systemctl status kubelet

# Try starting kubelet and inspect status again
systemctl start kubelet
systemctl status kubelet

# Check kubelet binary path
whereis kubelet

# Fix kubelet systemd drop-in
vi /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf
# Ensure the final command uses:
# ExecStart=/usr/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_KUBEADM_ARGS $KUBELET_EXTRA_ARGS

# Reload systemd and restart kubelet
systemctl daemon-reload
systemctl restart kubelet
systemctl status kubelet

# Confirm node is Ready
kubectl get nodes

# Create the requested Pod
kubectl run success --image=nginx:1-alpine -n default

# Verify Pod is running
kubectl get pod success -n default -o wide
