#!/bin/bash
set -e

mkdir -p /opt/course/v4/16
for ns in project-alpha project-beta project-gamma; do
  kubectl create ns "$ns" --dry-run=client -o yaml | kubectl apply -f -
  kubectl -n "$ns" delete role --all --ignore-not-found
done

kubectl -n project-alpha create role role-a --verb=get --resource=pods --dry-run=client -o yaml | kubectl apply -f -
kubectl -n project-beta create role role-b1 --verb=get --resource=pods --dry-run=client -o yaml | kubectl apply -f -
kubectl -n project-beta create role role-b2 --verb=list --resource=pods --dry-run=client -o yaml | kubectl apply -f -
kubectl -n project-beta create role role-b3 --verb=watch --resource=pods --dry-run=client -o yaml | kubectl apply -f -
kubectl -n project-gamma create role role-c --verb=get --resource=pods --dry-run=client -o yaml | kubectl apply -f -

rm -f /opt/course/v4/16/resources.txt /opt/course/v4/16/crowded-namespace.txt

echo "Question 16 setup complete"
