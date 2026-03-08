#!/bin/bash
set -e

# Ensure the directory for outputs exists
mkdir -p /opt/course/7

# TODO: Prepare a working etcd cluster or ensure etcd static pod is running on kubeadm-type cluster. Snapshot step assumes local access to etcdctl and certificate files at /etc/kubernetes/pki/etcd/
# For exam environments, etcd and the required certificates should already be present.
