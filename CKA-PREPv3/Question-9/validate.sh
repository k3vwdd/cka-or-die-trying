#!/bin/bash
set -euo pipefail

pass() {
  echo "PASS: $1"
}

fail() {
  echo "FAIL: $1"
  exit 1
}

# 1) kube-scheduler manifest must be restored
if [ ! -f /etc/kubernetes/manifests/kube-scheduler.yaml ]; then
  fail "kube-scheduler manifest is not present at /etc/kubernetes/manifests/kube-scheduler.yaml"
fi
pass "kube-scheduler manifest restored"

# 2) kube-scheduler pod should exist again after restart
if ! kubectl -n kube-system get pods | grep -q kube-scheduler; then
  fail "kube-scheduler pod is not visible in kube-system"
fi
pass "kube-scheduler pod visible"

# 3) manual-schedule pod must exist
if ! kubectl get pod manual-schedule -n default >/dev/null 2>&1; then
  fail "Pod manual-schedule does not exist in default namespace"
fi
pass "manual-schedule pod exists"

# 4) manual-schedule image must be httpd:2-alpine
ms_image=$(kubectl get pod manual-schedule -n default -o jsonpath='{.spec.containers[0].image}')
if [ "$ms_image" != "httpd:2-alpine" ]; then
  fail "manual-schedule image is '$ms_image', expected 'httpd:2-alpine'"
fi
pass "manual-schedule image is correct"

# 5) manual-schedule must be manually scheduled to controlplane
ms_node=$(kubectl get pod manual-schedule -n default -o jsonpath='{.spec.nodeName}')
if [ "$ms_node" != "controlplane" ]; then
  fail "manual-schedule is on '$ms_node', expected 'controlplane'"
fi
pass "manual-schedule assigned to controlplane"

# 6) manual-schedule should be Running
ms_phase=$(kubectl get pod manual-schedule -n default -o jsonpath='{.status.phase}')
if [ "$ms_phase" != "Running" ]; then
  fail "manual-schedule phase is '$ms_phase', expected 'Running'"
fi
pass "manual-schedule is Running"

# 7) manual-schedule2 pod must exist
if ! kubectl get pod manual-schedule2 -n default >/dev/null 2>&1; then
  fail "Pod manual-schedule2 does not exist in default namespace"
fi
pass "manual-schedule2 pod exists"

# 8) manual-schedule2 image must be httpd:2-alpine
ms2_image=$(kubectl get pod manual-schedule2 -n default -o jsonpath='{.spec.containers[0].image}')
if [ "$ms2_image" != "httpd:2-alpine" ]; then
  fail "manual-schedule2 image is '$ms2_image', expected 'httpd:2-alpine'"
fi
pass "manual-schedule2 image is correct"

# 9) manual-schedule2 should be Running
ms2_phase=$(kubectl get pod manual-schedule2 -n default -o jsonpath='{.status.phase}')
if [ "$ms2_phase" != "Running" ]; then
  fail "manual-schedule2 phase is '$ms2_phase', expected 'Running'"
fi
pass "manual-schedule2 is Running"

# 10) manual-schedule2 should be scheduled by normal scheduler onto node01
ms2_node=$(kubectl get pod manual-schedule2 -n default -o jsonpath='{.spec.nodeName}')
if [ "$ms2_node" != "node01" ]; then
  fail "manual-schedule2 is on '$ms2_node', expected 'node01'"
fi
pass "manual-schedule2 scheduled onto node01"

echo "All validations passed."
