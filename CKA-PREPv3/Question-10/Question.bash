#!/bin/bash
# Question 10 | PV PVC Dynamic Provisioning

cat <<'EOF'
There is a backup Job that needs to be adjusted to store backups on a PVC.

Complete the following tasks:

1. Create a StorageClass named local-backup.

2. Configure the StorageClass with:
   - provisioner: rancher.io/local-path
   - volumeBindingMode: WaitForFirstConsumer
   - reclaimPolicy: Retain

3. Adjust the file /opt/course/10/backup.yaml so the backup Job uses a PersistentVolumeClaim instead of emptyDir.

4. In /opt/course/10/backup.yaml, add a PersistentVolumeClaim with:
   - name: backup-pvc
   - namespace: project-bern
   - accessModes: ReadWriteOnce
   - requested storage: 50Mi
   - storageClassName: local-backup

5. In the Job pod template, replace the backup volume definition:
   - remove emptyDir
   - use the PersistentVolumeClaim named backup-pvc

6. Deploy the changes.

7. Verify the following:
   - the Job completes once
   - the PVC is bound
   - the PVC is bound to a newly created PV

Note:
- To re-run a Job, delete it and create/apply it again.
EOF
