mkdir -p /opt/course/14

CONTROLPLANE_COUNT=$(kubectl get nodes -l node-role.kubernetes.io/control-plane --no-headers 2>/dev/null | wc -l)
TOTAL_NODES=$(kubectl get nodes --no-headers | wc -l)
WORKER_COUNT=$((TOTAL_NODES - CONTROLPLANE_COUNT))

SERVICE_CIDR=$(grep -oP '(?<=--service-cluster-ip-range=)\S+' /etc/kubernetes/manifests/kube-apiserver.yaml)

CNI_FILE=$(ls /etc/cni/net.d/*.conf /etc/cni/net.d/*.conflist 2>/dev/null | grep -v podman | head -n 1)
CNI_NAME=$(basename "$CNI_FILE")

CONTROLPLANE_NODE=$(kubectl get node -l node-role.kubernetes.io/control-plane -o jsonpath='{.items[0].metadata.name}')
STATIC_POD_SUFFIX="-${CONTROLPLANE_NODE}"

cat <<EOF > /opt/course/14/cluster-info
1: ${CONTROLPLANE_COUNT}
2: ${WORKER_COUNT}
3: ${SERVICE_CIDR}
4: ${CNI_NAME}, ${CNI_FILE}
5: ${STATIC_POD_SUFFIX}
EOF

cat /opt/course/14/cluster-info
