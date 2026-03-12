#!/bin/bash
set -euo pipefail

TP=$(kubectl -n qv4-11 get svc web-nodeport -o jsonpath='{.spec.ports[0].targetPort}')
[ "$TP" = "80" ] || { echo "FAIL: targetPort not fixed"; exit 1; }

NP=$(kubectl -n qv4-11 get svc web-nodeport -o jsonpath='{.spec.ports[0].nodePort}')
CP=$(kubectl get nodes -l node-role.kubernetes.io/control-plane -o jsonpath='{.items[0].metadata.name}')
CP_IP=$(kubectl get node "$CP" -o jsonpath='{.status.addresses[?(@.type=="InternalIP")].address}')

curl -sS --max-time 5 "http://${CP_IP}:${NP}" >/tmp/v4q11.out
grep -qi 'nginx' /tmp/v4q11.out || { echo "FAIL: NodePort unreachable"; exit 1; }

echo "PASS: Question 11"
