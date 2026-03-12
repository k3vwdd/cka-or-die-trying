#!/bin/bash
set -euo pipefail

OUT=/opt/course/v4/1/cluster-baseline.txt
[ -f "$OUT" ] || { echo "FAIL: output file missing"; exit 1; }

grep -q '^1: ' "$OUT" || { echo "FAIL: missing line 1"; exit 1; }
grep -q '^2: ' "$OUT" || { echo "FAIL: missing line 2"; exit 1; }
grep -q '^3: ' "$OUT" || { echo "FAIL: missing line 3"; exit 1; }
grep -q '^4: -' "$OUT" || { echo "FAIL: missing line 4 suffix"; exit 1; }

echo "PASS: Question 1"
