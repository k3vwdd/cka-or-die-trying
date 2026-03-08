#!/bin/bash
set -euo pipefail
ANS_FILE="/opt/course/14/cluster-info"
if [[ ! -s "$ANS_FILE" ]]; then
  echo "cluster-info file is missing or empty"; exit 1
fi
count=$(wc -l < "$ANS_FILE")
if [[ $count -ne 5 ]]; then
  echo "Expected 5 answers, found $count"; exit 1
fi
grep -q '^1: ' "$ANS_FILE" || { echo 'Missing answer 1'; exit 1; }
grep -q '^2: ' "$ANS_FILE" || { echo 'Missing answer 2'; exit 1; }
grep -q '^3: ' "$ANS_FILE" || { echo 'Missing answer 3'; exit 1; }
grep -q '^4: ' "$ANS_FILE" || { echo 'Missing answer 4'; exit 1; }
grep -q '^5: ' "$ANS_FILE" || { echo 'Missing answer 5'; exit 1; }
echo 'All expected answers present in required format.'
exit 0
