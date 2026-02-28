#!/bin/bash
set -e

mkdir -p /opt/course/16

if ! kubectl -n kube-system get cm coredns >/dev/null 2>&1; then
kubectl -n kube-system create cm coredns --from-literal=Corefile='.:53 {
    errors
    health
    ready
    kubernetes cluster.local in-addr.arpa ip6.arpa {
       pods insecure
       fallthrough in-addr.arpa ip6.arpa
       ttl 30
    }
    forward . /etc/resolv.conf
    cache 30
    loop
    reload
    loadbalance
}'
fi

rm -f /opt/course/16/coredns_backup.yaml

echo "Question 16 environment ready"
