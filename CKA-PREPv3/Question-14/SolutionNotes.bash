# 1. Count controlplane nodes
kubectl get nodes -l node-role.kubernetes.io/control-plane --no-headers | wc -l
# 2. Count worker nodes
TOTAL_NODES=$(kubectl get nodes --no-headers | wc -l)
CONTROLPLANE_COUNT=$(kubectl get nodes -l node-role.kubernetes.io/control-plane --no-headers | wc -l)
echo $((TOTAL_NODES - CONTROLPLANE_COUNT))
# 3. Find service CIDR used by the API server
cat /etc/kubernetes/manifests/kube-apiserver.yaml | grep -- --service-cluster-ip-range
# 4. Find CNI plugin config file & name
ls /etc/cni/net.d/*.conf /etc/cni/net.d/*.conflist 2>/dev/null | grep -v podman | head -n 1
basename [CNI FILE PATH]
# 5. Get static pod name suffix for controlplane node
kubectl get node -l node-role.kubernetes.io/control-plane -o jsonpath='{.items[0].metadata.name}'
# Use -[NODE_NAME] as the suffix
