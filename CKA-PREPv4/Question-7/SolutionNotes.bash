kubectl -n qv4-07 get pod api -o yaml > /tmp/qv4-07-api.yaml

# Edit /tmp/qv4-07-api.yaml and remove spec.nodeSelector
kubectl -n qv4-07 delete pod api
kubectl apply -f /tmp/qv4-07-api.yaml

kubectl -n qv4-07 get pod api -w
