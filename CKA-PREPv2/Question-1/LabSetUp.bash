#!/bin/bash
set -e

mkdir -p /opt/course/1

[ -f /opt/course/1/kubeconfig ] || {
  echo "Missing required file: /opt/course/1/kubeconfig"
  echo "Use the real exam/lab environment for this question."
  exit 1
}

rm -f /opt/course/1/contexts /opt/course/1/current-context /opt/course/1/cert

echo "Question 1 environment ready at /opt/course/1"
