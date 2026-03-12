#!/bin/bash
set -euo pipefail

PHASE=$(kubectl -n qv4-07 get pod api -o jsonpath='{.status.phase}' 2>/dev/null || true)
[ "$PHASE" = "Running" ] || { echo "FAIL: pod api not running"; exit 1; }

echo "PASS: Question 7"
