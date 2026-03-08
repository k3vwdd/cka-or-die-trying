#!/bin/bash
set -euo pipefail

output_file="/opt/course/8/controlplane-components.txt"
expected="kubelet: process
kube-apiserver: static-pod
kube-scheduler: static-pod
kube-controller-manager: static-pod
etcd: static-pod
dns: pod coredns"

if [ ! -f "$output_file" ]; then
  echo "FAIL: $output_file does not exist" >&2
  exit 1
fi

actual=$(cat "$output_file")

if [ "$actual" != "$expected" ]; then
  echo "FAIL: Output in $output_file does not match expected format." >&2
  echo "Expected:\n$expected" >&2
  echo "Got:\n$actual" >&2
  exit 2
fi

echo "PASS: Controlplane Components file is correct."
