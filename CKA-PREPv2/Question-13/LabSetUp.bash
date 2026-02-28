#!/bin/bash
set -e

mkdir -p /opt/course/13
kubectl create ns project-r500 --dry-run=client -o yaml | kubectl apply -f -

if ! kubectl get crd gatewayclasses.gateway.networking.k8s.io >/dev/null 2>&1; then
kubectl apply -f - <<'EOF'
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: gatewayclasses.gateway.networking.k8s.io
spec:
  group: gateway.networking.k8s.io
  names:
    kind: GatewayClass
    listKind: GatewayClassList
    plural: gatewayclasses
    singular: gatewayclass
  scope: Cluster
  versions:
  - name: v1
    served: true
    storage: true
    schema:
      openAPIV3Schema:
        type: object
        x-kubernetes-preserve-unknown-fields: true
---
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: gateways.gateway.networking.k8s.io
spec:
  group: gateway.networking.k8s.io
  names:
    kind: Gateway
    listKind: GatewayList
    plural: gateways
    singular: gateway
  scope: Namespaced
  versions:
  - name: v1
    served: true
    storage: true
    schema:
      openAPIV3Schema:
        type: object
        x-kubernetes-preserve-unknown-fields: true
---
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: httproutes.gateway.networking.k8s.io
spec:
  group: gateway.networking.k8s.io
  names:
    kind: HTTPRoute
    listKind: HTTPRouteList
    plural: httproutes
    singular: httproute
  scope: Namespaced
  versions:
  - name: v1
    served: true
    storage: true
    schema:
      openAPIV3Schema:
        type: object
        x-kubernetes-preserve-unknown-fields: true
EOF
fi

kubectl apply -f - <<'EOF'
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: nginx
spec:
  controllerName: example.net/mock-gateway-controller
---
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: main
  namespace: project-r500
spec:
  gatewayClassName: nginx
  listeners:
  - name: http
    protocol: HTTP
    port: 80
EOF

kubectl -n project-r500 apply -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-desktop
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web-desktop
  template:
    metadata:
      labels:
        app: web-desktop
    spec:
      containers:
      - name: web
        image: nginx:stable
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-mobile
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web-mobile
  template:
    metadata:
      labels:
        app: web-mobile
    spec:
      containers:
      - name: web
        image: nginx:stable
---
apiVersion: v1
kind: Service
metadata:
  name: web-desktop
spec:
  selector:
    app: web-desktop
  ports:
  - port: 80
    targetPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: web-mobile
spec:
  selector:
    app: web-mobile
  ports:
  - port: 80
    targetPort: 80
EOF

cat > /opt/course/13/ingress.yaml <<'EOF'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: traffic-director
spec:
  ingressClassName: nginx
  rules:
  - host: r500.gateway
    http:
      paths:
      - path: /desktop
        pathType: Prefix
        backend:
          service:
            name: web-desktop
            port:
              number: 80
      - path: /mobile
        pathType: Prefix
        backend:
          service:
            name: web-mobile
            port:
              number: 80
EOF

kubectl -n project-r500 delete httproute traffic-director --ignore-not-found >/dev/null 2>&1 || true

echo "Question 13 environment ready at /opt/course/13"
