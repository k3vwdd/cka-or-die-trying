# 1. Create the StorageClass with the specified settings
echo 'Create StorageClass local-backup with local-path provisioner, Retain policy, WaitForFirstConsumer mode.'
cat <<'EOF' > /tmp/local-backup-sc.yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-backup
provisioner: rancher.io/local-path
reclaimPolicy: Retain
volumeBindingMode: WaitForFirstConsumer
EOF
kubectl apply -f /tmp/local-backup-sc.yaml

# 2. Edit /opt/course/10/backup.yaml:
#   - Add the PVC requesting 50Mi with storageClassName: local-backup.
#   - Mount the PVC in place of emptyDir for the backup Job.
# PVC manifest (to be added):
# apiVersion: v1
# kind: PersistentVolumeClaim
# metadata:
#   name: backup-pvc
#   namespace: project-bern
# spec:
#   accessModes: [ReadWriteOnce]
#   resources:
#     requests:
#       storage: 50Mi
#   storageClassName: local-backup
#
# In Job template, replace emptyDir with:
# - name: backup
#   persistentVolumeClaim:
#     claimName: backup-pvc

# 3. Re-deploy the updated resources
kubectl apply -f /opt/course/10/backup.yaml

# 4. Verify that backup Job completed once
kubectl -n project-bern get job backup
kubectl -n project-bern get pods -l job-name=backup

# 5. Verify PVC is Bound and that a new PV exists
kubectl -n project-bern get pvc backup-pvc
kubectl get pv
