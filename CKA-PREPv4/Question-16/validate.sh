#!/bin/bash
set -euo pipefail

[ -s /opt/course/v4/16/resources.txt ] || { echo "FAIL: resources.txt missing"; exit 1; }
[ -f /opt/course/v4/16/crowded-namespace.txt ] || { echo "FAIL: crowded-namespace missing"; exit 1; }

grep -q '^project-beta with 3 roles$' /opt/course/v4/16/crowded-namespace.txt || {
  echo "FAIL: crowded namespace result incorrect"
  exit 1
}

echo "PASS: Question 16"
