Question 15 | Event Forensics

1. Write a command into /opt/course/v4/15/cluster_events.sh that prints cluster-wide events sorted by metadata.creationTimestamp
2. Delete pod event-target in namespace qv4-15 and capture related latest events into /opt/course/v4/15/pod-delete.log
3. Recreate event-target and then force-remove its container with crictl; capture latest events into /opt/course/v4/15/container-kill.log
