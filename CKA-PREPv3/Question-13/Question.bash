#!/bin/bash
# Question 13 | Multi Containers and Pod shared Volume

# Create a Pod named multi-container-playground in Namespace default with multiple containers.
#
# Requirements:
# - Use a shared non-persistent volume mounted in each container
# - The volume must not be shared with other Pods
# - Container c1:
#   - image: nginx:1-alpine
#   - expose node name as environment variable MY_NODE_NAME
# - Container c2:
#   - image: busybox:1
#   - write current date every second to shared file /vol/date.log
# - Container c3:
#   - image: busybox:1
#   - stream /vol/date.log from the shared volume to stdout
#
# Verify by checking logs of container c3.
#
# Expected object details:
# - Pod name: multi-container-playground
# - Namespace: default
