#!/bin/bash
set -e

mkdir -p /opt/course/8

kubectl get nodes -o wide > /opt/course/8/nodes-before.txt

CP_NODE=$(kubectl get nodes -l node-role.kubernetes.io/control-plane -o jsonpath='{.items[0].metadata.name}')
[ -n "$CP_NODE" ] || CP_NODE=$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}')

CP_VERSION=$(kubectl get node "$CP_NODE" -o jsonpath='{.status.nodeInfo.kubeletVersion}')

cat > /opt/course/8/README <<EOF
Question 8 setup complete.

Control plane node: ${CP_NODE}
Control plane version: ${CP_VERSION}

Goal:
1) Ensure worker node kubelet/kubectl versions match control plane (${CP_VERSION}).
2) Join worker node to cluster using kubeadm join.
3) Verify workers are Ready.

Optional evidence file:
/opt/course/8/join-command
EOF

rm -f /opt/course/8/join-command

echo "Question 8 environment ready at /opt/course/8"
