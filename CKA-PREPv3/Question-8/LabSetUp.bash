#!/bin/bash
set -e

# Prepare the output directory for the lab
mkdir -p /opt/course/8
# Remove any pre-existing file
test ! -f /opt/course/8/controlplane-components.txt || rm /opt/course/8/controlplane-components.txt
