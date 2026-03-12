kubectl -n qv4-10 get svc api -o yaml

kubectl -n qv4-10 patch svc api -p '{"spec":{"selector":{"app":"api"}}}'

kubectl -n qv4-10 get endpoints api
kubectl -n qv4-10 exec debug -- curl -sS --max-time 5 http://api
