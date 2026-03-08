#!/bin/bash
# 1) Create manifest for first Pod
kubectl run ready-if-service-ready --image=nginx:1-alpine --dry-run=client -o yaml > /tmp/ready-if-service-ready.yaml

# 2) Edit manifest to add probes and then create Pod
# File: /tmp/ready-if-service-ready.yaml
# Under spec.containers[0], set:
# livenessProbe:
#   exec:
#     command:
#     - "true"
# readinessProbe:
#   exec:
#     command:
#     - sh
#     - -c
#     - wget -T2 -O- http://service-am-i-ready:80
kubectl apply -f /tmp/ready-if-service-ready.yaml

# 3) Confirm first Pod is not Ready initially
kubectl get pod ready-if-service-ready -n default
kubectl describe pod ready-if-service-ready -n default

# 4) Create second Pod with required label so service selects it
kubectl run am-i-ready --image=nginx:1-alpine --labels=id=cross-server-ready -n default

# 5) Verify service now has endpoint(s)
kubectl get svc service-am-i-ready -n default
kubectl get endpointslice -n default -l kubernetes.io/service-name=service-am-i-ready

# 6) Re-check first Pod readiness
kubectl get pod ready-if-service-ready -n default
