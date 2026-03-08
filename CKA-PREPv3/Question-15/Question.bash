# CKA Practice Lab: Cluster Event Logging

1. Write a kubectl command into /opt/course/15/cluster_events.sh that lists the latest cluster-wide events sorted by metadata.creationTimestamp.
2. Delete the kube-proxy Pod and write the related events to /opt/course/15/pod_kill.log.
3. Manually kill the kube-proxy container via the container runtime and write the resulting events to /opt/course/15/container_kill.log.
