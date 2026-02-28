kubectl -n kube-system get cm coredns -o yaml > /opt/course/16/coredns_backup.yaml

# Edit coredns Corefile and change kubernetes plugin line from:
# kubernetes cluster.local in-addr.arpa ip6.arpa {
# to:
# kubernetes custom-domain cluster.local in-addr.arpa ip6.arpa {

kubectl -n kube-system edit cm coredns
kubectl -n kube-system rollout restart deployment coredns
