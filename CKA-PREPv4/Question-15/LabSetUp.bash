#!/bin/bash
set -e

mkdir -p /opt/course/v4/15
kubectl create ns qv4-15 --dry-run=client -o yaml | kubectl apply -f -
kubectl -n qv4-15 delete pod event-target --ignore-not-found
kubectl -n qv4-15 run event-target --image=nginx:1-alpine --restart=Never
rm -f /opt/course/v4/15/cluster_events.sh /opt/course/v4/15/pod-delete.log /opt/course/v4/15/container-kill.log

echo "Question 15 setup complete"
