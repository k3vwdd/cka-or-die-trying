kubectl -n project-hamster run p2-pod --image=nginx:1-alpine
kubectl -n project-hamster expose pod p2-pod --name p2-service --port=3000 --target-port=80

sudo iptables-save | grep p2-service > /opt/course/p2/iptables.txt

kubectl -n project-hamster delete svc p2-service

# Confirm no related rules remain
sudo iptables-save | grep p2-service || true
