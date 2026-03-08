kubectl run pod1 --image=httpd:2-alpine --dry-run=client -o yaml > /tmp/pod1.yaml

# Edit /tmp/pod1.yaml and ensure:
# - metadata.name is pod1
# - spec.containers[0].name is pod1-container
# - image is httpd:2-alpine
# - add toleration:
#   tolerations:
#   - key: node-role.kubernetes.io/control-plane
#     effect: NoSchedule
# - add node selector:
#   nodeSelector:
#     node-role.kubernetes.io/control-plane: ""

kubectl apply -f /tmp/pod1.yaml
kubectl get pod pod1 -n default -o wide
