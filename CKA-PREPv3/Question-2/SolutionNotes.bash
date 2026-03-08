# 1) Move to manifest directory for static pods on controlplane
cd /etc/kubernetes/manifests

# 2) Generate static pod manifest for my-static-pod (image nginx:1-alpine)
kubectl run my-static-pod --image=nginx:1-alpine -o yaml --dry-run=client > my-static-pod.yaml

# 3) Edit my-static-pod.yaml to set resource requests to cpu: 10m, memory: 20Mi
# (Edit required section under spec.containers.resources.requests)

# 4) Confirm static pod creation
kubectl get pods -n default | grep my-static-pod

# 5) Find the node name for the controlplane
# Node name required for static pod naming (e.g., my-static-pod-<nodeName>)
# Example: NODE_NAME=$(kubectl get node -o jsonpath='{.items[0].metadata.name}')

# 6) Expose the static pod with a NodePort service
kubectl expose pod my-static-pod-<controlplane-node-name> --name static-pod-service --type=NodePort --port=80 -n default

# 7) Validate the service, endpoints, and reachability
kubectl get svc static-pod-service -n default
kubectl get endpointslice -n default -l kubernetes.io/service-name=static-pod-service

# Check NodePort and internal IP
echo "Check service via curl:"
NODE_PORT=$(kubectl get svc static-pod-service -n default -o jsonpath='{.spec.ports[0].nodePort}')
NODE_IP=$(kubectl get node <controlplane-node-name> -o jsonpath='{.status.addresses[?(@.type=="InternalIP")].address}')
curl "${NODE_IP}:${NODE_PORT}"
