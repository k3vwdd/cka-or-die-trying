kubectl create namespace secret

kubectl apply -f /opt/course/11/secret1.yaml -n secret

kubectl -n secret create secret generic secret2 \
  --from-literal=user=user1 \
  --from-literal=pass=1234

kubectl -n secret run secret-pod --image=busybox:1 --dry-run=client -o yaml -- sh -c "sleep 1d" > /tmp/secret-pod.yaml

Edit /tmp/secret-pod.yaml and configure the Pod so that:
- spec.containers[0].env includes:
  - name: APP_USER
    valueFrom.secretKeyRef.name: secret2
    valueFrom.secretKeyRef.key: user
  - name: APP_PASS
    valueFrom.secretKeyRef.name: secret2
    valueFrom.secretKeyRef.key: pass
- spec.volumes includes a Secret volume using the Secret created from /opt/course/11/secret1.yaml
- spec.containers[0].volumeMounts mounts that Secret at /tmp/secret1 with readOnly: true

kubectl apply -f /tmp/secret-pod.yaml

kubectl -n secret exec secret-pod -- env | grep APP_
kubectl -n secret exec secret-pod -- ls -la /tmp/secret1
