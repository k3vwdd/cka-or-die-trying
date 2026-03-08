kubectl -n lima-control get configmap control-config -o yaml
kubectl -n lima-control edit configmap control-config
# Set DNS_1=kubernetes.default.svc.cluster.local
# Set DNS_2=department.lima-workload.svc.cluster.local
# Set DNS_3=section100.section.lima-workload.svc.cluster.local
# Set DNS_4=1-2-3-4.kube-system.pod.cluster.local
kubectl -n lima-control rollout restart deployment controller
kubectl -n lima-control rollout status deployment controller
POD_NAME=$(kubectl -n lima-control get pods -l app=controller -o jsonpath='{.items[0].metadata.name}')
kubectl -n lima-control exec -it "$POD_NAME" -- nslookup kubernetes.default.svc.cluster.local
kubectl -n lima-control exec -it "$POD_NAME" -- nslookup department.lima-workload.svc.cluster.local
kubectl -n lima-control exec -it "$POD_NAME" -- nslookup section100.section.lima-workload.svc.cluster.local
kubectl -n lima-control exec -it "$POD_NAME" -- nslookup 1-2-3-4.kube-system.pod.cluster.local
