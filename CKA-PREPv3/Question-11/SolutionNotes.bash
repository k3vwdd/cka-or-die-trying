# 1. Create the namespace
kubectl create namespace secret

# 2. Apply the secret1 manifest
kubectl apply -f /opt/course/11/secret1.yaml -n secret

# 3. Create secret2 with specific keys
kubectl -n secret create secret generic secret2 --from-literal=user=user1 --from-literal=pass=1234

# 4. Create the pod manifest with dry-run for editing
kubectl -n secret run secret-pod --image=busybox:1 --dry-run=client -o yaml -- sh -c "sleep 1d" > /tmp/secret-pod.yaml

# 5. Edit /tmp/secret-pod.yaml:
#    - Under spec.containers[0].env, add:
#        - name: APP_USER
#          valueFrom:
#            secretKeyRef:
#              name: secret2
#              key: user
#        - name: APP_PASS
#          valueFrom:
#            secretKeyRef:
#              name: secret2
#              key: pass
#    - Under spec.volumes, add:
#        - name: secret1-vol
#          secret:
#            secretName: secret1
#    - Under spec.containers[0].volumeMounts, add:
#        - name: secret1-vol
#          mountPath: /tmp/secret1
#          readOnly: true

# 6. Apply the pod manifest
kubectl -n secret apply -f /tmp/secret-pod.yaml

# 7. Verify env vars
kubectl -n secret exec secret-pod -- env | grep APP_

# 8. Verify secret1 volume mount
kubectl -n secret exec secret-pod -- ls -la /tmp/secret1
