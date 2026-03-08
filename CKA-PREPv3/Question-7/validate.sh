#!/bin/bash
set -euo pipefail

VERSION_FILE="/opt/course/7/etcd-version"
SNAPSHOT_FILE="/opt/course/7/etcd-snapshot.db"

fail() {
  echo "FAIL: $1"
  exit 1
}

pass() {
  echo "PASS: $1"
}

[ -f "$VERSION_FILE" ] || fail "Expected etcd version output file at $VERSION_FILE"
[ -s "$VERSION_FILE" ] || fail "etcd version output file exists but is empty"

if ! grep -qi "etcd" "$VERSION_FILE"; then
  fail "etcd version file does not appear to contain etcd --version output"
fi
pass "etcd version file exists and contains etcd output"

[ -f "$SNAPSHOT_FILE" ] || fail "Expected etcd snapshot file at $SNAPSHOT_FILE"
[ -s "$SNAPSHOT_FILE" ] || fail "etcd snapshot file exists but is empty"
pass "etcd snapshot file exists and is non-empty"

if command -v etcdctl >/dev/null 2>&1; then
  SNAPSHOT_STATUS_OUTPUT=$(ETCDCTL_API=3 etcdctl snapshot status "$SNAPSHOT_FILE" 2>/dev/null || true)
  if [ -z "$SNAPSHOT_STATUS_OUTPUT" ]; then
    fail "Unable to read snapshot status from $SNAPSHOT_FILE using etcdctl"
  fi
  if ! printf '%s' "$SNAPSHOT_STATUS_OUTPUT" | grep -Eq 'HASH|REVISION|TOTAL KEY|TOTAL SIZE|hash|revision'; then
    fail "Snapshot status output did not look valid for $SNAPSHOT_FILE"
  fi
  pass "etcd snapshot is readable by etcdctl"
else
  fail "etcdctl command not found; cannot validate snapshot integrity"
fi

echo "All validations passed for Question 7 | Etcd Operations"
