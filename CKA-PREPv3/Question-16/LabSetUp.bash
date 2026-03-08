#!/bin/bash
set -e
# Prepare the lab directory
mkdir -p /opt/course/16
# Optionally clean any previous files for idempotency
touch /opt/course/16/resources.txt
rm -f /opt/course/16/resources.txt /opt/course/16/crowded-namespace.txt
