#!/bin/bash
set -euo pipefail

# Check that resources.txt exists and is non-empty
if [[ ! -s /opt/course/16/resources.txt ]]; then
  echo "/opt/course/16/resources.txt is missing or empty" >&2
  exit 1
fi

# Ensure at least one resource entry is present
if ! grep -q '^' /opt/course/16/resources.txt; then
  echo "/opt/course/16/resources.txt has no resource entries" >&2
  exit 1
fi

# Check crowded-namespace.txt exists and format
if [[ ! -f /opt/course/16/crowded-namespace.txt ]]; then
  echo "/opt/course/16/crowded-namespace.txt is missing" >&2
  exit 1
fi

# Validate format - look for 'project-' in the output and 'roles'
if ! grep -qE '^project-.* with [0-9]+ roles$' /opt/course/16/crowded-namespace.txt; then
  echo "/opt/course/16/crowded-namespace.txt has unexpected format" >&2
  exit 1
fi

exit 0
