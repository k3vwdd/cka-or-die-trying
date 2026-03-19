#!/bin/bash
set -e

mkdir -p /opt/course/13
kubectl create ns project-r500 --dry-run=client -o yaml | kubectl apply -f -
kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.5.0/standard-install.yaml
helm pull oci://ghcr.io/nginx/charts/nginx-gateway-fabric --untar && cd nginx-gateway-fabric
helm install ngf . --create-namespace -n nginx-gateway

kubectl apply -f - <<'EOF'
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: nginx
spec:
  controllerName: nginx.org/nginx-gateway-controller
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
    nodePort: 30080
EOF

kubectl -n project-r500 apply -f - <<'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: web-desktop-site
data:
  desktop/index.html: |
    Web Desktop App
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: web-mobile-site
data:
  mobile/index.html: |
    Web Mobile App
---
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
        volumeMounts:
        - name: site-content
          mountPath: /usr/share/nginx/html
      volumes:
      - name: site-content
        configMap:
          name: web-desktop-site
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
        volumeMounts:
        - name: site-content
          mountPath: /usr/share/nginx/html
      volumes:
      - name: site-content
        configMap:
          name: web-mobile-site
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
