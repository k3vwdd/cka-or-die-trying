#!/bin/bash
set -euo pipefail

echo "Validating Question 8..."

CP_NODE=$(kubectl get nodes -l node-role.kubernetes.io/control-plane -o jsonpath='{.items[0].metadata.name}')
[ -n "$CP_NODE" ] || CP_NODE=$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}')

CP_VERSION=$(kubectl get node "$CP_NODE" -o jsonpath='{.status.nodeInfo.kubeletVersion}')

WORKERS=$(kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | awk -v cp="$CP_NODE" '$0!=cp{print}')
[ -n "$WORKERS" ] || { echo "FAIL: no worker nodes found in cluster"; exit 1; }

for w in $WORKERS; do
  W_STATUS=$(kubectl get node "$w" -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}')
  [ "$W_STATUS" = "True" ] || { echo "FAIL: worker $w is not Ready"; exit 1; }

  W_VERSION=$(kubectl get node "$w" -o jsonpath='{.status.nodeInfo.kubeletVersion}')
  [ "$W_VERSION" = "$CP_VERSION" ] || { echo "FAIL: worker $w version $W_VERSION does not match control plane $CP_VERSION"; exit 1; }
done

if [ -f /opt/course/8/join-command ]; then
  grep -Eq '^kubeadm join [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:6443 --token [a-z0-9]+\.[a-z0-9]+ --discovery-token-ca-cert-hash sha256:[a-f0-9]{64}$' /opt/course/8/join-command \
    || { echo "FAIL: /opt/course/8/join-command exists but format is invalid"; exit 1; }
fi

echo "SUCCESS: Question 8 passed"
