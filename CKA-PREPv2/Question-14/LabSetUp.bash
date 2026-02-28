#!/bin/bash
set -e

mkdir -p /opt/course/14

CERT_PATH=/etc/kubernetes/pki/apiserver.crt
[ -f "$CERT_PATH" ] || {
  echo "Missing ${CERT_PATH}"
  echo "Run this question on a control-plane node with kubeadm-managed certs."
  exit 1
}

echo "$CERT_PATH" > /opt/course/14/cert-path

openssl x509 -noout -enddate -in "$CERT_PATH" | cut -d= -f2 > /opt/course/14/expected-expiration.txt

command -v kubeadm >/dev/null 2>&1 || {
  echo "kubeadm is required for this question"
  exit 1
}

kubeadm certs check-expiration > /opt/course/14/kubeadm-check-expiration.txt

rm -f /opt/course/14/expiration /opt/course/14/kubeadm-renew-certs.sh

echo "Question 14 environment ready at /opt/course/14"
