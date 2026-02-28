#!/bin/bash
set -e

mkdir -p /opt/course/1

cat > /opt/course/1/expected-cert.pem <<'EOF'
-----BEGIN CERTIFICATE-----
MIIBZzCCAQ2gAwIBAgIUQ0tBLVBSRVB2Mi1kZW1vLWNlcnQwCgYIKoZIzj0EAwIw
EzERMA8GA1UEAwwIYWNjb3VudDAeFw0yNjAxMDEwMDAwMDBaFw0zNjAxMDEwMDAw
MDBaMBMxETAPBgNVBAMMCGFjY291bnQwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNC
AASzVJqJ2EUq9fzn92z9e6o8W9a0yLxM2YzV0cA8xqf3hK6mXx4a9f3W2y1uQhHj
0QjW0nQ6y0C1r2zP0r8j8YQFo1MwUTAdBgNVHQ4EFgQUprepv2demo0000000000
MAsGA1UdDwQEAwIFoDATBgNVHSUEDDAKBggrBgEFBQcDAjAKBggqhkjOPQQDAgNH
ADBEAiA0v9v6J1a8lJw9Ar4gP4sXlW8o2KpZ1j4x5k6b7c8YFQIgQ0W4hQ9NQd8X
2H3YV5Q0j5D8k2M4M2qV6h3Y2v0fF7k=
-----END CERTIFICATE-----
EOF

CERT_B64=$(base64 -w0 /opt/course/1/expected-cert.pem)

cat > /opt/course/1/kubeconfig <<EOF
apiVersion: v1
kind: Config
clusters:
- cluster:
    server: https://127.0.0.1:6443
    insecure-skip-tls-verify: true
  name: internal
contexts:
- context:
    cluster: internal
    user: account-0027@internal
  name: account-0027@internal
- context:
    cluster: internal
    user: account-0042@internal
  name: account-0042@internal
current-context: account-0042@internal
users:
- name: account-0027@internal
  user:
    client-certificate-data: ${CERT_B64}
- name: account-0042@internal
  user:
    token: demo-token
EOF

rm -f /opt/course/1/contexts /opt/course/1/current-context /opt/course/1/cert

echo "Question 1 environment ready at /opt/course/1"
