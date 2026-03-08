# 1) Generate pod manifest template
kubectl run pod1 --image=httpd:2-alpine --dry-run=client -o yaml > /tmp/pod1.yaml

# 2) Edit manifest to satisfy constraints
# File: /tmp/pod1.yaml
# Ensure container name is pod1-container
# Add toleration for control-plane taint:
#   tolerations:
#   - key: node-role.kubernetes.io/control-plane
#     effect: NoSchedule
# Add node selector so it schedules only to controlplane nodes:
#   nodeSelector:
#     node-role.kubernetes.io/control-plane: ""

# 3) Apply pod manifest
kubectl apply -f /tmp/pod1.yaml

# 4) Verify pod is running on controlplane node
kubectl get pod pod1 -n default -o wide
