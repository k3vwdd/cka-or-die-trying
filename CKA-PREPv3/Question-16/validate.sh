#!/bin/bash
set -euo pipefail

RES_FILE="/opt/course/16/resources.txt"
CROWD_FILE="/opt/course/16/crowded-namespace.txt"

fail() {
  echo "FAIL: $1"
  exit 1
}

pass() {
  echo "PASS"
  exit 0
}

[ -f "$RES_FILE" ] || fail "Missing file $RES_FILE"
[ -f "$CROWD_FILE" ] || fail "Missing file $CROWD_FILE"

EXPECTED_RES=$(mktemp)
ACTUAL_RES=$(mktemp)
kubectl api-resources --namespaced -o name | sed '/^$/d' | sort > "$EXPECTED_RES"
sed '/^$/d' "$RES_FILE" | sort > "$ACTUAL_RES"

if ! diff -u "$EXPECTED_RES" "$ACTUAL_RES" >/dev/null 2>&1; then
  echo "Expected namespaced resources:"
  cat "$EXPECTED_RES"
  echo "Actual namespaced resources:"
  cat "$ACTUAL_RES"
  fail "Contents of $RES_FILE do not match namespaced API resources"
fi

EXPECTED_COUNT=0
EXPECTED_NS=""
while IFS= read -r ns; do
  count=$(kubectl -n "$ns" get roles --no-headers 2>/dev/null | wc -l | tr -d ' ')
  if [ "$count" -gt "$EXPECTED_COUNT" ]; then
    EXPECTED_COUNT="$count"
    EXPECTED_NS="$ns"
  fi
done < <(kubectl get ns -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | grep '^project-' || true)

EXPECTED_LINE="$EXPECTED_NS with $EXPECTED_COUNT roles"
ACTUAL_LINE=$(tr -d '\r' < "$CROWD_FILE" | head -n 1)

if [ "$ACTUAL_LINE" != "$EXPECTED_LINE" ]; then
  echo "Expected crowded namespace line: $EXPECTED_LINE"
  echo "Actual crowded namespace line:   $ACTUAL_LINE"
  fail "Contents of $CROWD_FILE are incorrect"
fi

if [ -z "$EXPECTED_NS" ]; then
  fail "No project-* namespaces found to validate against"
fi

pass
