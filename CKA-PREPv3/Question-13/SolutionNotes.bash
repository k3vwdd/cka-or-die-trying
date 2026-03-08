# 1) Generate base manifest
kubectl run multi-container-playground --image=nginx:1-alpine --dry-run=client -o yaml > /tmp/multi-container-playground.yaml

# 2) Edit /tmp/multi-container-playground.yaml as follows:
# - Change metadata:name to multi-container-playground
# - In spec:containers:
#   - Rename the single container to c1, keep image nginx:1-alpine
#   - Add env to c1: MY_NODE_NAME from fieldRef spec.nodeName
#   - Add container c2:
#       name: c2
#       image: busybox:1
#       command: ["sh", "-c", "while true; do date >> /vol/date.log; sleep 1; done"]
#   - Add container c3:
#       name: c3
#       image: busybox:1
#       command: ["sh", "-c", "tail -f /vol/date.log"]
# - Set volumeMounts in all containers to mount at /vol using volume "vol"
# - Add spec.volumes with:
#     - name: vol
#       emptyDir: {}

# 3) Apply the manifest
kubectl apply -f /tmp/multi-container-playground.yaml

# 4) Check pod status
kubectl get pod multi-container-playground -n default

# 5) Confirm c1 env var
kubectl exec -n default multi-container-playground -c c1 -- env | grep MY_NODE_NAME

# 6) Fetch logs from c3 to verify streaming dates
kubectl logs -n default multi-container-playground -c c3
