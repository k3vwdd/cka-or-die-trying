# CKA Practice Lab: Create Secret and Mount into Pod

# 1. In the Namespace 'secret':
#    a. Create a Pod named 'secret-pod' using image 'busybox:1' and keep it running (e.g. 'sleep 1d').
#    b. Mount the existing Secret created from /opt/course/11/secret1.yaml into the Pod as a read-only volume at /tmp/secret1.
# 2. Create a Secret named 'secret2' with keys 'user=user1' and 'pass=1234' in namespace 'secret'.
# 3. Expose the 'user' and 'pass' values from 'secret2' as environment variables APP_USER and APP_PASS in the Pod's container.
