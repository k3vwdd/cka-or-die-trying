#!/bin/bash
set -e

mkdir -p /opt/course/v4/2
cp /etc/kubernetes/admin.conf /opt/course/v4/2/kubeconfig
rm -f /opt/course/v4/2/contexts /opt/course/v4/2/current-context /opt/course/v4/2/current-server

echo "Question 2 setup complete"
