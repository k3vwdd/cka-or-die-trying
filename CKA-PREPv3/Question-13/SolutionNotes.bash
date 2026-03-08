kubectl run multi-container-playground --image=nginx:1-alpine --dry-run=client -o yaml > /tmp/multi-container-playground.yaml

# Edit /tmp/multi-container-playground.yaml so that:
# - metadata.name is multi-container-playground
# - namespace is default
# - container c1 uses image nginx:1-alpine
# - c1 has env var MY_NODE_NAME from fieldRef spec.nodeName
# - add container c2 with image busybox:1
#   command: sh -c "while true; do date >> /vol/date.log; sleep 1; done"
# - add container c3 with image busybox:1
#   command: sh -c "tail -f /vol/date.log"
# - add volume:
#   - name: vol
#     emptyDir: {}
# - mount /vol in c1, c2, and c3

kubectl apply -f /tmp/multi-container-playground.yaml
kubectl get pod multi-container-playground -n default
kubectl exec -n default multi-container-playground -c c1 -- env | grep MY_NODE_NAME
kubectl logs -n default multi-container-playground -c c3
