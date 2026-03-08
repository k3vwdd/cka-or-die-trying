#!/bin/bash
set -euo pipefail

FILE="/opt/course/8/controlplane-components.txt"

fail() {
  echo "FAIL: $1"
  exit 1
}

pass() {
  echo "PASS"
  exit 0
}

[ -f "$FILE" ] || fail "Expected file $FILE to exist"

line_count=$(wc -l < "$FILE")
[ "$line_count" -eq 6 ] || fail "Expected exactly 6 lines in $FILE, got $line_count"

allowed_type='(not-installed|process|static-pod|pod)'

grep -Eq '^kubelet: '
