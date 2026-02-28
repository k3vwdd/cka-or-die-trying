#!/bin/bash
set -e

ROOT=/opt/course/5/api-gateway
mkdir -p "$ROOT/base" "$ROOT/staging" "$ROOT/prod"

kubectl create ns api-gateway-staging --dry-run=client -o yaml | kubectl apply -f -
kubectl create ns api-gateway-prod --dry-run=client -o yaml | kubectl apply -f -

cat > "$ROOT/base/deployment.yaml" <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-gateway
spec:
  replicas: 1
  selector:
    matchLabels:
      app: api-gateway
  template:
    metadata:
      labels:
        app: api-gateway
    spec:
      containers:
      - name: api
        image: nginx:stable
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 100m
            memory: 64Mi
EOF

cat > "$ROOT/base/horizontal-scaling-config.yaml" <<'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: horizontal-scaling-config
data:
  scale: "legacy"
EOF

cat > "$ROOT/base/kustomization.yaml" <<'EOF'
resources:
  - deployment.yaml
  - horizontal-scaling-config.yaml
EOF

cat > "$ROOT/staging/kustomization.yaml" <<'EOF'
namespace: api-gateway-staging
resources:
  - ../base
EOF

cat > "$ROOT/prod/kustomization.yaml" <<'EOF'
namespace: api-gateway-prod
resources:
  - ../base
EOF

kubectl kustomize "$ROOT/staging" | kubectl apply -f -
kubectl kustomize "$ROOT/prod" | kubectl apply -f -

echo "Question 5 environment ready at $ROOT"
