#!/bin/bash
set -e

mkdir -p /opt/course/p1

[ -f /etc/kubernetes/manifests/etcd.yaml ] || {
  echo "Missing /etc/kubernetes/manifests/etcd.yaml"
  echo "Run this question on a control-plane node with static etcd."
  exit 1
}

rm -f /opt/course/p1/etcd-info.txt

echo "Preview Question 1 environment ready at /opt/course/p1"
