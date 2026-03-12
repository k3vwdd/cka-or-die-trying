kubectl -n qv4-11 get svc web-nodeport -o yaml

kubectl -n qv4-11 patch svc web-nodeport -p '{"spec":{"ports":[{"port":80,"targetPort":80,"protocol":"TCP","nodePort":30080}]}}'

CP=$(kubectl get nodes -l node-role.kubernetes.io/control-plane -o jsonpath='{.items[0].metadata.name}')
CP_IP=$(kubectl get node "$CP" -o jsonpath='{.status.addresses[?(@.type=="InternalIP")].address}')
curl -sS --max-time 5 "http://${CP_IP}:30080"
