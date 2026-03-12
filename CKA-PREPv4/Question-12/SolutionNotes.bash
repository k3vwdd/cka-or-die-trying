kubectl -n qv4-12 get svc
kubectl -n qv4-12 describe pod dns-check

# Create the expected service DNS name
kubectl -n qv4-12 expose deployment web --name web-internal --port 80 --target-port 80

kubectl -n qv4-12 get pod dns-check -w
