#!/bin/bash
set -euo pipefail

echo "Validating Preview Question 1..."

[ -f /opt/course/p1/etcd-info.txt ] || { echo "FAIL: /opt/course/p1/etcd-info.txt missing"; exit 1; }
[ -f /etc/kubernetes/manifests/etcd.yaml ] || { echo "FAIL: /etc/kubernetes/manifests/etcd.yaml missing"; exit 1; }

KEY_PATH=$(grep -oE -- '--key-file=[^ ]+' /etc/kubernetes/manifests/etcd.yaml | cut -d= -f2)
CERT_PATH=$(grep -oE -- '--cert-file=[^ ]+' /etc/kubernetes/manifests/etcd.yaml | cut -d= -f2)
CLIENT_AUTH=$(grep -oE -- '--client-cert-auth=[^ ]+' /etc/kubernetes/manifests/etcd.yaml | cut -d= -f2)

[ -n "$KEY_PATH" ] || { echo "FAIL: could not parse --key-file from etcd manifest"; exit 1; }
[ -n "$CERT_PATH" ] || { echo "FAIL: could not parse --cert-file from etcd manifest"; exit 1; }
[ -f "$CERT_PATH" ] || { echo "FAIL: cert file $CERT_PATH does not exist"; exit 1; }

EXPIRATION=$(openssl x509 -noout -enddate -in "$CERT_PATH" | cut -d= -f2)
if [ "$CLIENT_AUTH" = "true" ]; then
  ENABLED="yes"
else
  ENABLED="no"
fi

EXPECTED=$(cat <<EOF
Server private key location: ${KEY_PATH}
Server certificate expiration date: ${EXPIRATION}
Is client certificate authentication enabled: ${ENABLED}
EOF
)
ACTUAL=$(cat /opt/course/p1/etcd-info.txt)

[ "$EXPECTED" = "$ACTUAL" ] || {
  echo "FAIL: etcd info content is incorrect"
  echo "Expected:"
  cat /opt/course/p1/expected-etcd-info.txt
  echo "Actual:"
  cat /opt/course/p1/etcd-info.txt
  exit 1
}

echo "SUCCESS: Preview Question 1 passed"
