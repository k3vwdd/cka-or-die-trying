#!/bin/bash
set -euo pipefail

echo "Validating Question 14..."

[ -f /opt/course/14/expiration ] || { echo "FAIL: /opt/course/14/expiration missing"; exit 1; }
[ -f /opt/course/14/kubeadm-renew-certs.sh ] || { echo "FAIL: /opt/course/14/kubeadm-renew-certs.sh missing"; exit 1; }
[ -f /opt/course/14/cert-path ] || { echo "FAIL: /opt/course/14/cert-path missing"; exit 1; }
[ -f /opt/course/14/kubeadm-check-expiration.txt ] || { echo "FAIL: /opt/course/14/kubeadm-check-expiration.txt missing"; exit 1; }

CERT_PATH=$(cat /opt/course/14/cert-path)
[ -f "$CERT_PATH" ] || { echo "FAIL: certificate path $CERT_PATH does not exist"; exit 1; }

EXPECTED=$(openssl x509 -noout -enddate -in "$CERT_PATH" | cut -d= -f2)
ACTUAL=$(cat /opt/course/14/expiration)
[ "$EXPECTED" = "$ACTUAL" ] || { echo "FAIL: expiration does not match certificate"; exit 1; }

grep -q 'apiserver' /opt/course/14/kubeadm-check-expiration.txt || { echo "FAIL: kubeadm check output missing apiserver entry"; exit 1; }

grep -Eq '^kubeadm certs renew apiserver[[:space:]]*$' /opt/course/14/kubeadm-renew-certs.sh \
  || { echo "FAIL: renew command incorrect"; exit 1; }

echo "SUCCESS: Question 14 passed"
