kubectl -n qv4-08 describe pod -l app=checkout

kubectl -n qv4-08 set image deployment/checkout app=nginx:1-alpine
kubectl -n qv4-08 rollout status deployment/checkout
