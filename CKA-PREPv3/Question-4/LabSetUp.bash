#!/bin/bash
set -e

# Prepare namespace-scoped resources required by the lab.
# The question states that an existing Service named service-am-i-ready should be present.

kubectl get namespace default >/dev/null

if ! kubectl get service service-am-i-ready -n default >/dev/null 2>&1; then
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: service-am-i-ready
  namespace: default
spec:
  selector:
    id: cross-server-ready
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
EOF
fi
