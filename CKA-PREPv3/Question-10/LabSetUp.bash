#!/bin/bash
set -e
# Prepare environment for the dynamic provisioning PV/PVC lab
# Place a sample backup.yaml manifest if it doesn't exist (with an emptyDir originally)

mkdir -p /opt/course/10
if ! grep -q 'kind: Job' /opt/course/10/backup.yaml 2>/dev/null; then
  cat <<EOF > /opt/course/10/backup.yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: backup
  namespace: project-bern
spec:
  template:
    spec:
      containers:
      - name: backup
        image: busybox
        command: ["sh", "-c", "echo backup > /backup/data.txt && sleep 2"]
        volumeMounts:
        - name: backup
          mountPath: /backup
      restartPolicy: OnFailure
      volumes:
      - name: backup
        emptyDir: {}
EOF
fi

# Ensure the namespace exists
kubectl get ns project-bern >/dev/null 2>&1 || kubectl create ns project-bern

# Remove old lab StorageClass, PVC, and PV (ignore errors)
kubectl delete storageclass local-backup --ignore-not-found
kubectl -n project-bern delete pvc backup-pvc --ignore-not-found
kubectl delete pv -l lab=cka-10 --ignore-not-found
# Remove previous backup Job if present
kubectl -n project-bern delete job backup --ignore-not-found
