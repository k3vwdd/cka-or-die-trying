mkdir -p /opt/course/7
ETCD_POD=$(kubectl -n kube-system get pods -l component=etcd -o jsonpath='{.items[0].metadata.name}')
kubectl -n kube-system exec "$ETCD_POD" -- etcd --version > /opt/course/7/etcd-version
ETCDCTL_API=3 etcdctl snapshot save /opt/course/7/etcd-snapshot.db --cacert /etc/kubernetes/pki/etcd/ca.crt --cert /etc/kubernetes/pki/etcd/server.crt --key /etc/kubernetes/pki/etcd/server.key
ls -l /opt/course/7/etcd-version /opt/course/7/etcd-snapshot.db
