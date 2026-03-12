kubectl -n qv4-09 describe pod -l app=payments

kubectl -n qv4-09 patch deployment payments --type='json' \
  -p='[{"op":"replace","path":"/spec/template/spec/containers/0/readinessProbe/httpGet/path","value":"/"}]'

kubectl -n qv4-09 rollout status deployment/payments
