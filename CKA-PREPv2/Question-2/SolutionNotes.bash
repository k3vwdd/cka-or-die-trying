kubectl create namespace minio

*search the hub to get the helm repo name:

helm search hub minio-operator -o json | jq
helm repo add minio https://operator.min.io
helm repo update
helm -n minio install minio-operator minio/operator

# Edit /opt/course/2/minio-tenant.yaml and set:
# spec.features.enableSFTP: true

kubectl apply -f /opt/course/2/minio-tenant.yaml
kubectl -n minio get tenant
