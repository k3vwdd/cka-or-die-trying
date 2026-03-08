cd /etc/kubernetes/manifests
kubectl run my-static-pod --image=nginx:1-alpine -o yaml --dry-run=client > my-static-pod.yaml

# Edit /etc/kubernetes/manifests/my-static-pod.yaml and ensure it contains:
# metadata:
#   name: my-static-pod
#   labels:
#     run: my-static-pod
# spec:
#   containers:
#   - name: my-static-pod
#     image: nginx:1-alpine
#     resources:
#       requests:
#         cpu: 10m
#         memory: 20Mi

kubectl get pods -n default | grep my-static-pod

POD_NAME=$(kubectl get pod -n default -l run=my-static-pod -o jsonpath='{.items[0].metadata.name}')
kubectl expose pod "$POD_NAME" --name static-pod-service --type=NodePort --port=80

kubectl get svc static-pod-service -n default
kubectl get endpointslice -n default -l kubernetes.io/service-name=static-pod-service

NODE_PORT=$(kubectl get svc static-pod-service -n default -o jsonpath='{.spec.ports[0].nodePort}')
CONTROLPLANE_NODE=$(kubectl get node -l node-role.kubernetes.io/control-plane -o jsonpath='{.items[0].metadata.name}')
NODE_IP=$(kubectl get node "$CONTROLPLANE_NODE" -o jsonpath='{.status.addresses[?(@.type=="InternalIP")].address}')
curl "${NODE_IP}:${NODE_PORT}"
