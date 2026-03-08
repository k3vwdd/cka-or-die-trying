# CKA Practice Lab: PV PVC Dynamic Provisioning

# 1. Create a StorageClass named local-backup with:
#    - provisioner: rancher.io/local-path
#    - volumeBindingMode: WaitForFirstConsumer
#    - reclaim policy set to retain PV after PVC deletion
# 2. Adjust /opt/course/10/backup.yaml so that backups are stored on a PVC.
#    - Add a PVC requesting 50Mi storage, using StorageClass local-backup.
#    - Use the PVC in place of any emptyDir volume in the backup Job manifest.
# 3. Deploy the changes.
# 4. Verify that:
#    - The backup Job completes once.
#    - The PVC is bound to a newly created PV.
