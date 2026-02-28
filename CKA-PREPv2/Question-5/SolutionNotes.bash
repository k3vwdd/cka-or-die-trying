cd /opt/course/5/api-gateway

# Remove legacy ConfigMap references from base/staging/prod as needed.
# Add HPA to base (apiVersion autoscaling/v2):
# - minReplicas: 2
# - maxReplicas: 4
# - target CPU averageUtilization: 50

# Add prod overlay patch to set:
# - maxReplicas: 6

kubectl kustomize staging | kubectl apply -f -
kubectl kustomize prod | kubectl apply -f -

kubectl -n api-gateway-staging delete cm horizontal-scaling-config --ignore-not-found
kubectl -n api-gateway-prod delete cm horizontal-scaling-config --ignore-not-found
