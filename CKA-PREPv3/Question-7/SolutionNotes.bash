# 1. Ensure output directory exists:
mkdir -p /opt/course/7

# 2. Get the etcd pod name (when running under kubeadm):
ETCD_POD=$(kubectl -n kube-system get pods -l component=etcd -o jsonpath='{.items[0].metadata.name}')

# 3. Capture etcd version from inside the etcd pod:
kubectl -n kube-system exec "$ETCD_POD" -- etcd --version > /opt/course/7/etcd-version

# 4. Create an etcd snapshot using etcdctl and local certificates:
ETCDCTL_API=3 etcdctl snapshot save /opt/course/7/etcd-snapshot.db \
  --cacert /etc/kubernetes/pki/etcd/ca.crt \
  --cert /etc/kubernetes/pki/etcd/server.crt \
  --key /etc/kubernetes/pki/etcd/server.key

# 5. Verify outputs exist:
ls -l /opt/course/7/etcd-version /opt/course/7/etcd-snapshot.db
