#!/bin/bash
set -euo pipefail

fail() {
  echo "FAILED: $1"
  exit 1
}

pass() {
  echo "PASS: $1"
}

CONF="/usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf"
EXPECTED='ExecStart=/usr/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_KUBEADM_ARGS $KUBELET_EXTRA_ARGS'

if [ ! -f "$CONF" ]; then
  fail "kubelet systemd drop-in file not found at $CONF"
fi

if ! grep -Fqx "$EXPECTED" "$CONF"; then
  echo "Current ExecStart lines in $CONF:"
  grep -n '^ExecStart=' "$CONF" || true
  fail "kubelet ExecStart is not fixed to /usr/bin/kubelet"
fi
pass "kubelet systemd drop-in points to /usr/bin/kubelet"

if ! systemctl is-active --quiet kubelet; then
  systemctl status kubelet --no-pager || true
  fail "kubelet service is not active"
fi
pass "kubelet service is active"

READY_STATUS=$(kubectl get node controlplane -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null || true)
if [ "$READY_STATUS" != "True" ]; then
  kubectl get nodes -o wide || true
  fail "controlplane node is not Ready"
fi
pass "controlplane node is Ready"

POD_NAME=$(kubectl get pod success -n default --no-headers 2>/dev/null | awk '{print $1}' || true)
if [ "$POD_NAME" != "success" ]; then
  kubectl get pods -n default || true
  fail "Pod success not found in namespace default"
fi
pass "Pod success exists in namespace default"

POD_IMAGE=$(kubectl get pod success -n default -o jsonpath='{.spec.containers[0].image}' 2>/dev/null || true)
if [ "$POD_IMAGE" != "nginx:1-alpine" ]; then
  fail "Pod success is not using image nginx:1-alpine"
fi
pass "Pod success uses image nginx:1-alpine"

POD_PHASE=$(kubectl get pod success -n default -o jsonpath='{.status.phase}' 2>/dev/null || true)
if [ "$POD_PHASE" != "Running" ]; then
  kubectl get pod success -n default -o wide || true
  kubectl describe pod success -n default || true
  fail "Pod success is not Running"
fi
pass "Pod success is Running"

echo "All validations passed."
