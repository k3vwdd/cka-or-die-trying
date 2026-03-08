#!/bin/bash
set -e

# This lab relies on pre-existing cluster resources referenced in the task.
# Only perform safe existence checks and leave TODO markers where source input
# does not provide enough information to create missing resources.

kubectl get ns lima-control >/dev/null 2>&1 || echo "TODO: Namespace lima-control must already exist"
kubectl get ns lima-workload >/dev/null 2>&1 || echo "TODO: Namespace lima-workload must already exist"
kubectl get ns kube-system >/dev/null 2>&1 || true
kubectl get ns default >/dev/null 2>&1 || true

kubectl -n lima-control get configmap control-config >/dev/null 2>&1 || echo "TODO: ConfigMap control-config must already exist in namespace lima-control"
kubectl -n lima-control get deployment controller >/dev/null 2>&1 || echo "TODO: Deployment controller must already exist in namespace lima-control"
kubectl -n lima-workload get svc department >/dev/null 2>&1 || echo "TODO: Headless Service department must already exist in namespace lima-workload"
kubectl -n lima-workload get pod section100 >/dev/null 2>&1 || echo "TODO: Pod section100 must already exist in namespace lima-workload"
kubectl -n lima-workload get svc section >/dev/null 2>&1 || echo "TODO: Headless Service section should exist in namespace lima-workload for stable Pod DNS section100.section.lima-workload.svc.cluster.local"

exit 0
