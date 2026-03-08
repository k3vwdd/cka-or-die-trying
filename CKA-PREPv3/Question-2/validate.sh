#!/bin/bash
set -euo pipefail

# 1) Validate static pod manifest exists
if [[ ! -f /etc/kubernetes/manifests/my-static-pod.yaml ]]; then
  echo "Static pod manifest not found at /etc/kubernetes/manifests/my-static-pod.yaml" >&2
  exit 1
fi

grep 'image: nginx:1-alpine' /etc/kubernetes/manifests/my-static-pod.yaml >/dev/null || {
  echo "Static pod manifest missing correct image" >&2
  exit 1
}
grep 'cpu: 10m' /etc/kubernetes/manifests/my-static-pod.yaml >/dev/null || {
  echo "Static pod manifest missing cpu request" >&2
  exit 1
}
grep 'memory: 20Mi' /etc/kubernetes/manifests/my-static-pod.yaml >/dev/null || {
  echo "Static pod manifest missing memory request" >&2
  exit 1
}

# 2) Static pod is running
kubectl get pod -n default | grep my-static-pod

# 3) Ensure NodePort service exists
kubectl get svc static-pod-service -n default

# 4) Ensure service has one endpoint
EP_CT=$(kubectl get endpointslice -n default -l kubernetes.io/service-name=static-pod-service -o jsonpath='{.items[0].endpoints[*].addresses}' | wc -w)
if [[ "$EP_CT" != "1" ]]; then
  echo "Service does not have exactly one endpoint (found $EP_CT)" >&2
  exit 1
fi

# 5) Confirm service and pod are reachable
SVC_JSON=$(kubectl get svc static-pod-service -n default -o json)
NODE_PORT=$(echo "$SVC_JSON" | grep nodePort | head -1 | awk '{print $2}' | tr -d ',')
NODE=$(kubectl get pod -n default -o wide | grep my-static-pod | awk '{print $7}')
NODE_IP=$(kubectl get node "$NODE" -o jsonpath='{.status.addresses[?(@.type=="InternalIP")].address}')

STATUS=0
set +e
curl -m 5 -s "${NODE_IP}:${NODE_PORT}" | grep -i nginx >/dev/null || STATUS=1
set -e
if [[ $STATUS != 0 ]]; then
  echo "FAILED: Pod not reachable via service NodePort $NODE_PORT on $NODE_IP" >&2
  exit 1
fi

echo "Validation passed: Static pod and service working as expected."
