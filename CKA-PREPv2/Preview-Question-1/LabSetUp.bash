#!/bin/bash
set -e

mkdir -p /opt/course/p1

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /opt/course/p1/server.key \
  -out /opt/course/p1/server.crt \
  -subj "/CN=etcd-server-lab" >/dev/null 2>&1

EXPIRATION=$(openssl x509 -noout -enddate -in /opt/course/p1/server.crt | cut -d= -f2)

cat > /opt/course/p1/etcd.yaml <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: etcd
  namespace: kube-system
spec:
  containers:
  - command:
    - etcd
    - --cert-file=/opt/course/p1/server.crt
    - --key-file=/opt/course/p1/server.key
    - --client-cert-auth=true
    - --trusted-ca-file=/opt/course/p1/ca.crt
    image: registry.k8s.io/etcd:3.5.15-0
    name: etcd
EOF

cat > /opt/course/p1/expected-etcd-info.txt <<EOF
Server private key location: /opt/course/p1/server.key
Server certificate expiration date: ${EXPIRATION}
Is client certificate authentication enabled: yes
EOF

rm -f /opt/course/p1/etcd-info.txt

echo "Preview Question 1 environment ready at /opt/course/p1"
