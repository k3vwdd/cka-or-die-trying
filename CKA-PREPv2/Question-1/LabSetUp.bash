#!/bin/bash
set -e

mkdir -p /opt/course/1

if [ ! -f /opt/course/1/kubeconfig ]; then
  SRC_KUBECONFIG=""
  [ -f /etc/kubernetes/admin.conf ] && SRC_KUBECONFIG=/etc/kubernetes/admin.conf
  [ -z "$SRC_KUBECONFIG" ] && [ -f "$HOME/.kube/config" ] && SRC_KUBECONFIG="$HOME/.kube/config"

  [ -n "$SRC_KUBECONFIG" ] || {
    echo "Could not find a source kubeconfig (checked /etc/kubernetes/admin.conf and ~/.kube/config)"
    exit 1
  }

  API_SERVER=$(kubectl --kubeconfig "$SRC_KUBECONFIG" config view --raw -o jsonpath='{.clusters[0].cluster.server}')
  [ -n "$API_SERVER" ] || API_SERVER="https://127.0.0.1:6443"

  CERT_B64=$(kubectl --kubeconfig "$SRC_KUBECONFIG" config view --raw -o jsonpath='{.users[0].user.client-certificate-data}')
  if [ -z "$CERT_B64" ] && [ -f /etc/kubernetes/pki/apiserver.crt ]; then
    CERT_B64=$(base64 -w0 /etc/kubernetes/pki/apiserver.crt)
  fi

  [ -n "$CERT_B64" ] || {
    echo "Could not determine certificate data for account-0027"
    exit 1
  }

  cat > /opt/course/1/kubeconfig <<EOF
apiVersion: v1
kind: Config
clusters:
- cluster:
    server: ${API_SERVER}
    insecure-skip-tls-verify: true
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: admin@internal
  name: cluster-admin
- context:
    cluster: kubernetes
    user: account-0027@internal
  name: cluster-w100
- context:
    cluster: kubernetes
    user: account-0028@internal
  name: cluster-w200
current-context: cluster-w200
users:
- name: admin@internal
  user:
    token: dummy-admin-token
- name: account-0027@internal
  user:
    client-certificate-data: ${CERT_B64}
- name: account-0028@internal
  user:
    token: dummy-user-token
EOF
fi

rm -f /opt/course/1/contexts /opt/course/1/current-context /opt/course/1/cert

echo "Question 1 environment ready at /opt/course/1"
