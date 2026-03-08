# Inspect current ConfigMap
yaml_output=$(kubectl -n lima-control get configmap control-config -o yaml)
echo "$yaml_output"

# Edit ConfigMap
kubectl -n lima-control edit configmap control-config
# Set the following in its data section:
# DNS_1=kubernetes.default.svc.cluster.local
# DNS_2=department.lima-workload.svc.cluster.local
# DNS_3=section100.section.lima-workload.svc.cluster.local
# DNS_4=1-2-3-4.kube-system.pod.cluster.local

# Restart the Deployment to pick up ConfigMap changes
kubectl -n lima-control rollout restart deployment controller

# Get a controller pod name
POD_NAME=$(kubectl -n lima-control get pods -l app=controller -o jsonpath='{.items[0].metadata.name}')

# Verify DNS resolution from inside the pod
kubectl -n lima-control exec -it "$POD_NAME" -- nslookup kubernetes.default.svc.cluster.local
kubectl -n lima-control exec -it "$POD_NAME" -- nslookup department.lima-workload.svc.cluster.local
kubectl -n lima-control exec -it "$POD_NAME" -- nslookup section100.section.lima-workload.svc.cluster.local
kubectl -n lima-control exec -it "$POD_NAME" -- nslookup 1-2-3-4.kube-system.pod.cluster.local
