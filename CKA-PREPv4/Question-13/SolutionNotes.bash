cat <<'EOF' | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-client
  namespace: qv4-13
spec:
  podSelector:
    matchLabels:
      app: app
  policyTypes: ["Ingress"]
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: client
    ports:
    - protocol: TCP
      port: 80
EOF

kubectl -n qv4-13 exec client -- curl -sS --max-time 5 http://app-svc
