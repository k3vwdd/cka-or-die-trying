#!/bin/bash
set -euo pipefail

# 1. Check StorageClass exists and properties
sc=$(kubectl get storageclass local-backup -o json)
provisioner=$(echo "$sc" | grep 'rancher.io/local-path')
volume_binding=$(echo "$sc" | grep 'WaitForFirstConsumer')
retain=$(echo "$sc" | grep -i retain)
if [ -z "$provisioner" ] || [ -z "$volume_binding" ] || [ -z "$retain" ]; then
  echo 'StorageClass local-backup missing required settings.'
  exit 1
fi

echo '✔ StorageClass local-backup exists with correct settings.'

# 2. Check PVC exists, is correct size, class, and is Bound
pvc=$(kubectl -n project-bern get pvc backup-pvc -o json)
stat=$(echo "$pvc" | jq -r .status.phase)
req=$(echo "$pvc" | jq -r .spec.resources.requests.storage)
scn=$(echo "$pvc" | jq -r .spec.storageClassName)
if [ "$stat" != "Bound" ]; then
  echo 'PVC not Bound.'
  exit 1
fi
if [ "$req" != "50Mi" ]; then
  echo 'PVC request size should be 50Mi.'
  exit 1
fi
if [ "$scn" != "local-backup" ]; then
  echo 'PVC is not using the local-backup StorageClass.'
  exit 1
fi

echo '✔ PVC is bound and uses the correct StorageClass and size.'

# 3. Check a PV is Bound to this PVC
pv=$(kubectl get pv -o json | jq -r '.items[] | select(.spec.claimRef.name=="backup-pvc" and .spec.claimRef.namespace=="project-bern") | .metadata.name')
if [ -z "$pv" ]; then
  echo 'No PV is bound to backup-pvc.'
  exit 1
fi

echo "✔ PV $pv is bound to backup-pvc."

# 4. Check Job exists, has run once and succeeded
job=$(kubectl -n project-bern get job backup -o json)
succeeded=$(echo "$job" | jq -r .status.succeeded)
if [ "$succeeded" != "1" ]; then
  echo 'Backup job did not complete successfully once.'
  exit 1
fi

echo '✔ Backup Job completed successfully once.'

# 5. Check that Job pod used PVC volume
pod=$(kubectl -n project-bern get pods -l job-name=backup -o json | jq -r '.items[0].metadata.name')
vol=$(kubectl -n project-bern get pod "$pod" -o json | jq -r '.spec.volumes[] | select(.persistentVolumeClaim.claimName=="backup-pvc") | .name')
if [ -z "$vol" ]; then
  echo 'Backup job pod did not mount the backup-pvc as volume.'
  exit 1
fi

echo '✔ Backup job pod used backup-pvc.'

echo 'All checks passed!'
