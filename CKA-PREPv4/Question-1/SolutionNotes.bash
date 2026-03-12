mkdir -p /opt/course/v4/1

CP_COUNT=$(kubectl get nodes -l node-role.kubernetes.io/control-plane --no-headers 2>/dev/null | wc -l)
TOTAL=$(kubectl get nodes --no-headers | wc -l)
WK_COUNT=$((TOTAL - CP_COUNT))
SVC_CIDR=$(grep -oP '(?<=--service-cluster-ip-range=)\S+' /etc/kubernetes/manifests/kube-apiserver.yaml)
CP_NODE=$(kubectl get nodes -l node-role.kubernetes.io/control-plane -o jsonpath='{.items[0].metadata.name}')

cat <<EOF > /opt/course/v4/1/cluster-baseline.txt
1: ${CP_COUNT}
2: ${WK_COUNT}
3: ${SVC_CIDR}
4: -${CP_NODE}
EOF
