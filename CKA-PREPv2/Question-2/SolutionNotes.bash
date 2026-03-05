kubectl create namespace minio

helm repo add minio https://operator.min.io
helm repo update

# If a previous setup left CRDs behind, clear them to avoid
# Helm CRD apply conflicts on .spec.versions
kubectl delete crd tenants.minio.min.io miniojobs.job.min.io policybindings.sts.min.io --ignore-not-found

helm -n minio install minio-operator minio/operator

# Edit /opt/course/2/minio-tenant.yaml and set:
# spec.features.enableSFTP: true

kubectl apply -f /opt/course/2/minio-tenant.yaml
kubectl -n minio get tenant
