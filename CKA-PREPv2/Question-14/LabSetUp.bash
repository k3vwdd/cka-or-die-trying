#!/bin/bash
set -e

mkdir -p /opt/course/14

CERT_PATH=/etc/kubernetes/pki/apiserver.crt

if [ ! -f "$CERT_PATH" ]; then
  CERT_PATH=/opt/course/14/apiserver.crt
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /opt/course/14/apiserver.key \
    -out /opt/course/14/apiserver.crt \
    -subj "/CN=kube-apiserver-lab" >/dev/null 2>&1
fi

echo "$CERT_PATH" > /opt/course/14/cert-path

openssl x509 -noout -enddate -in "$CERT_PATH" | cut -d= -f2 > /opt/course/14/expected-expiration.txt

if command -v kubeadm >/dev/null 2>&1; then
  kubeadm certs check-expiration > /opt/course/14/kubeadm-check-expiration.txt 2>/dev/null || true
fi

if [ ! -s /opt/course/14/kubeadm-check-expiration.txt ]; then
  EXP=$(cat /opt/course/14/expected-expiration.txt)
  cat > /opt/course/14/kubeadm-check-expiration.txt <<EOF
CERTIFICATE                EXPIRES                  RESIDUAL TIME   CERTIFICATE AUTHORITY   EXTERNALLY MANAGED
apiserver                  ${EXP}      --            ca                      no
EOF
fi

rm -f /opt/course/14/expiration /opt/course/14/kubeadm-renew-certs.sh

echo "Question 14 environment ready at /opt/course/14"
