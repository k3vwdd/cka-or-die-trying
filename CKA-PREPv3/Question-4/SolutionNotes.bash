# 1. Generate the Pod manifest for ready-if-service-ready
kubectl run ready-if-service-ready --image=nginx:1-alpine --dry-run=client -o yaml > /tmp/ready-if-service-ready.yaml

# 2. Edit /tmp/ready-if-service-ready.yaml and add the following under spec.containers[0]:
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

# 3. Create the Pod
kubectl apply -f /tmp/ready-if-service-ready.yaml

# 4. Confirm the Pod is NOT Ready (readiness probe should fail)
kubectl get pod ready-if-service-ready -n default
kubectl describe pod ready-if-service-ready -n default

# 5. Create the second Pod with the correct label
kubectl run am-i-ready --image=nginx:1-alpine --labels=id=cross-server-ready -n default

# 6. Confirm the Service selects the Pod as endpoint
kubectl get svc service-am-i-ready -n default
kubectl get endpointslice -n default -l kubernetes.io/service-name=service-am-i-ready

# 7. Confirm ready-if-service-ready Pod is now Ready
kubectl get pod ready-if-service-ready -n default
