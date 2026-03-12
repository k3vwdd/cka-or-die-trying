#!/bin/bash
set -euo pipefail

OUT=/opt/course/v4/3/certificate-info.txt
[ -f "$OUT" ] || { echo "FAIL: output missing"; exit 1; }

grep -q '^Issuer:' "$OUT" || { echo "FAIL: issuer missing"; exit 1; }
grep -q 'X509v3 Extended Key Usage:' "$OUT" || { echo "FAIL: eku missing"; exit 1; }

echo "PASS: Question 3"
