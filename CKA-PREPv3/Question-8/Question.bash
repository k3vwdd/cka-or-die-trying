Determine how these controlplane components are started/installed:
- kubelet
- kube-apiserver
- kube-scheduler
- kube-controller-manager
- etcd

Also determine the DNS application name and how it is started/installed.

Write your findings to:
/opt/course/8/controlplane-components.txt

Required output format:
kubelet: [TYPE]
kube-apiserver: [TYPE]
kube-scheduler: [TYPE]
kube-controller-manager: [TYPE]
etcd: [TYPE]
dns: [TYPE] [NAME]

Allowed [TYPE] values:
- not-installed
- process
- static-pod
- pod

Expected investigation steps:
1. Ensure the output directory exists.
2. Identify how kubelet is started/installed.
3. Identify whether kube-apiserver, kube-scheduler, kube-controller-manager, and etcd are started from static pod manifests.
4. Confirm running controlplane pods in kube-system.
5. Identify the DNS application name and how it is started/installed.
6. Write the final findings to /opt/course/8/controlplane-components.txt in the exact required format.
7. Verify the file contents.
