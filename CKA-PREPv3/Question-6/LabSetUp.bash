#!/bin/bash
set -e
# Simulate the kubelet broken state by misconfiguring the ExecStart in kubelet's systemd drop-in
if [[ $(hostname) == "controlplane" ]]; then
  # Backup original 10-kubeadm.conf if exists
  if [ -f /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf ]; then
    cp /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf.bak
    # Corrupt the ExecStart binary path to simulate an issue
    sed -i 's|^ExecStart=.*|ExecStart=/wrong/path/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_KUBEADM_ARGS $KUBELET_EXTRA_ARGS|' /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf
    systemctl daemon-reload
    systemctl stop kubelet || true
  fi
fi
# Remove the pod if it exists
test -x $(command -v kubectl) && kubectl delete pod success -n default --ignore-not-found=true
