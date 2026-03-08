#!/bin/bash
set -e

# Create namespaces
kubectl create namespace lima-control || true
kubectl create namespace lima-workload || true
kubectl create namespace kube-system || true

# Deploy a standard Service "kubernetes" in the default namespace if not present
# (Usually exists by default, but ensure it)
kubectl get service kubernetes -n default || kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: kubernetes
  namespace: default
spec:
  ports:
  - port: 443
    targetPort: 6443
  clusterIP: 10.96.0.1
EOF

# Create a headless Service "department" in lima-workload
yaml_headless=$(cat <<EOF
apiVersion: v1
kind: Service
metadata:
  name: department
  namespace: lima-workload
spec:
  clusterIP: None
  selector:
    app: department
  ports:
  - port: 80
EOF
)
echo "$yaml_headless" | kubectl apply -f -

# Deploy a Pod that matches the headless Service
kubectl apply -n lima-workload -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: section100
  labels:
    app: department
    section: section
EOF
spec:
  containers:
  - name: nginx
    image: nginx
    ports:
    - containerPort: 80
EOF

# Create a dummy Pod in kube-system with IP 1.2.3.4 (cannot guarantee IP, place a TODO for manual assign)
# TODO: Manually assign a Pod in kube-system the IP 1.2.3.4 if your cluster allows

# Create ConfigMap control-config in lima-control with placeholder values
kubectl apply -n lima-control -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: control-config
  namespace: lima-control
  labels:
    app: controller
  data:
    DNS_1: ""
    DNS_2: ""
    DNS_3: ""
    DNS_4: ""
EOF

# Deploy a sample Deployment using this ConfigMap in lima-control
kubectl apply -n lima-control -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: controller
spec:
  replicas: 1
  selector:
    matchLabels:
      app: controller
  template:
    metadata:
      labels:
        app: controller
    spec:
      containers:
      - name: main
        image: busybox
        command: ["sleep", "3600"]
        envFrom:
        - configMapRef:
            name: control-config
EOF
