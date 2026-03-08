#!/bin/bash
set -e
# Make sure the output directory exists and is empty
mkdir -p /opt/course/3/
: > /opt/course/3/certificate-info.txt

# Nothing else needed; environment assumed to be configured for multinode/kubeadm
