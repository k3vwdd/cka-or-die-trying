#!/bin/bash
set -euo pipefail

if [[ ! -f /opt/course/7/etcd-version ]]; then
  echo 'etcd-version file missing!'
  exit 1
fi
if [[ ! -s /opt/course/7/etcd-version ]]; then
  echo 'etcd-version file is empty!'
  exit 1
fi

if [[ ! -f /opt/course/7/etcd-snapshot.db ]]; then
  echo 'etcd-snapshot.db file missing!'
  exit 1
fi
if [[ ! -s /opt/course/7/etcd-snapshot.db ]]; then
  echo 'etcd-snapshot.db file is empty!'
  exit 1
fi

# Further validation could involve checking file content for expected strings/patterns, if needed.
echo 'Validation passed: both outputs exist and are not empty.'
