kubectl -n qv4-17 patch svc app-svc -p '{"spec":{"selector":{"app":"app"}}}'

cat <<'EOF' | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-tester
  namespace: qv4-17
spec:
  podSelector:
    matchLabels:
      app: app
  policyTypes: ["Ingress"]
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: tester
    ports:
    - protocol: TCP
      port: 80
EOF

kubectl -n qv4-17 rollout status deployment/app
kubectl -n qv4-17 exec tester -- curl -sS --max-time 5 http://app-svc
