# CKA Practice Lab: Multi Containers and Pod Shared Volume
#
# Step-by-step instructions:
#
# 1. Create a Pod named multi-container-playground in the default Namespace.
# 2. The Pod must have three containers:
#    - c1: based on nginx:1-alpine image, expose the node name as env var MY_NODE_NAME.
#    - c2: based on busybox:1 image, write the current date every second to a file named date.log in a shared volume.
#    - c3: based on busybox:1 image, stream the shared date.log file to stdout using tail -f.
# 3. Use a shared, non-persistent (emptyDir) volume mounted at /vol in all containers. This should not be shared with other Pods.
# 4. Verify that the containers are configured correctly:
#    - c1 should have MY_NODE_NAME env var set from fieldRef:spec.nodeName.
#    - c2 should run: sh -c "while true; do date >> /vol/date.log; sleep 1; done"
#    - c3 should run: sh -c "tail -f /vol/date.log"
# 5. Apply and test the Pod setup. Confirm logs from c3 contain streaming dates.
