#!/bin/bash
# Check existing storage classes
kubectl get storageclass

# Create StorageClass local-backup
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

# Edit /opt/course/10/backup.yaml
# Add this PVC manifest before the Job manifest:
# apiVersion: v1
# kind: PersistentVolumeClaim
# metadata:
#   name: backup-pvc
#   namespace: project-bern
# spec:
#   accessModes:
#   - ReadWriteOnce
#   resources:
#     requests:
#       storage: 50Mi
#   storageClassName: local-backup
#
# In the Job spec, replace:
# volumes:
# - name: backup
#   emptyDir: {}
#
# with:
# volumes:
# - name: backup
#   persistentVolumeClaim:
#     claimName: backup-pvc

# Recreate Job so updated pod template runs with PVC
kubectl -n project-bern delete job backup --ignore-not-found
kubectl apply -f /opt/course/10/backup.yaml

# Verify Job completion and PVC/PV binding
kubectl -n project-bern get job backup
kubectl -n project-bern get pods -l job-name=backup
kubectl -n project-bern get pvc backup-pvc
kubectl get pv

# Optional re-run if needed
kubectl -n project-bern delete job backup
kubectl apply -f /opt/course/10/backup.yaml
