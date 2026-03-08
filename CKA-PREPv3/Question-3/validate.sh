#!/bin/bash
set -euo pipefail

if ! [ -s /opt/course/3/certificate-info.txt ]; then
  echo "certificate-info.txt does not exist or is empty" >&2
  exit 1
fi

grep -q 'Issuer:' /opt/course/3/certificate-info.txt || { echo "Missing Issuer lines"; exit 1; }
grep -q 'X509v3 Extended Key Usage:' /opt/course/3/certificate-info.txt || { echo "Missing Extended Key Usage lines"; exit 1; }
ISSUER_COUNT=$(grep -c '^Issuer:' /opt/course/3/certificate-info.txt || true)
EKU_COUNT=$(grep -c '^X509v3 Extended Key Usage:' /opt/course/3/certificate-info.txt || true)
if [ "$ISSUER_COUNT" -ne 2 ] || [ "$EKU_COUNT" -ne 2 ]; then
  echo "certificate-info.txt should have 2 Issuer and 2 EKU lines" >&2
  exit 1
fi

echo "Validation passed: certificate-info.txt contains required certificate details."
