#!/bin/bash
set -euo pipefail

DIR="/opt/course/5"
FILE1="$DIR/find_pods.sh"
FILE2="$DIR/find_pods_uid.sh"
EXPECTED1="kubectl get pods -A --sort-by=.metadata.creationTimestamp"
EXPECTED2="kubectl get pods -A --sort-by=.metadata.uid"

fail() {
  echo "FAIL: $1"
  exit 1
}

pass() {
  echo "PASS: $1"
}

[ -d "$DIR" ] || fail "Directory $DIR does not exist"
pass "Directory $DIR exists"

[ -f "$FILE1" ] || fail "$FILE1 does not exist"
pass "$FILE1 exists"

[ -f "$FILE2" ] || fail "$FILE2 does not exist"
pass "$FILE2 exists"

CONTENT1="$(tr -d '\r' < "$FILE1" | sed '/^[[:space:]]*$/d')"
CONTENT2="$(tr -d '\r' < "$FILE2" | sed '/^[[:space:]]*$/d')"

[ "$CONTENT1" = "$EXPECTED1" ] || fail "$FILE1 content is incorrect. Expected: $EXPECTED1"
pass "$FILE1 content is correct"

[ "$CONTENT2" = "$EXPECTED2" ] || fail "$FILE2 content is incorrect. Expected: $EXPECTED2"
pass "$FILE2 content is correct"

sh "$FILE1" >/dev/null 2>&1 || fail "$FILE1 failed to execute"
pass "$FILE1 executes successfully"

sh "$FILE2" >/dev/null 2>&1 || fail "$FILE2 failed to execute"
pass "$FILE2 executes successfully"

echo "All validations passed"
