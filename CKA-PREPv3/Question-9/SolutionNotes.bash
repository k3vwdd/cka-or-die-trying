#!/bin/bash
# 1) Stop kube-scheduler temporarily (static pod)
mv /etc/kubernetes/manifests/kube-scheduler.yaml /etc/kubernetes/

# 2) Confirm scheduler pod is gone
kubectl -n kube-system get pods | grep kube-scheduler

# 3) Create pod that should remain Pending without scheduler
kubectl run manual-schedule --image=httpd:2-alpine -n default
kubectl get pod manual-schedule -n default -o wide

# 4) Manually schedule pod by setting spec.nodeName to controlplane
kubectl get pod manual-schedule -n default -o yaml > /tmp/manual-schedule.yaml
# Edit /tmp/manual-schedule.yaml and set:
# spec:
#   nodeName: controlplane
kubectl replace --force -f /tmp/manual-schedule.yaml
kubectl get pod manual-schedule -n default -o wide

# 5) Start scheduler again
mv /etc/kubernetes/kube-scheduler.yaml /etc/kubernetes/manifests/
kubectl -n kube-system get pods | grep kube-scheduler

# 6) Create second pod and verify scheduler places it on node01
kubectl run manual-schedule2 --image=httpd:2-alpine -n default
kubectl get pod manual-schedule2 -n default -o wide
