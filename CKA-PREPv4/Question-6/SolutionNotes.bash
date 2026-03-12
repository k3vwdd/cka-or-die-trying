kubectl -n qv4-06 get pods
kubectl -n qv4-06 describe pod -l app=web

# Fix the bad startup command
kubectl -n qv4-06 patch deployment web --type='json' \
  -p='[{"op":"remove","path":"/spec/template/spec/containers/0/command"}]'

kubectl -n qv4-06 rollout status deployment/web
