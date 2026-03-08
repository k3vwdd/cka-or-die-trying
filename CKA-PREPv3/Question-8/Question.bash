# Question 8: Get Controlplane Information
#
# 1. Determine how these controlplane components are started/installed:
#    - kubelet
#    - kube-apiserver
#    - kube-scheduler
#    - kube-controller-manager
#    - etcd
# 2. Also determine the DNS application name and how it is started/installed.
# 3. Write your findings to:
#    /opt/course/8/controlplane-components.txt
# 4. Use the following output format (replace [TYPE] and [NAME] as appropriate):
#    kubelet: [TYPE]
#    kube-apiserver: [TYPE]
#    kube-scheduler: [TYPE]
#    kube-controller-manager: [TYPE]
#    etcd: [TYPE]
#    dns: [TYPE] [NAME]
#
# Allowed [TYPE] values:
#   - not-installed
#   - process
#   - static-pod
#   - pod
#
# Guidance:
# - Use systemctl to check kubelet
# - Check /etc/kubernetes/manifests for static pods
# - Use kubectl to identify DNS application and its type
# - Write your findings in EXACT format above
# - Verify your output file
