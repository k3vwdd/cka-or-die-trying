# Question 17 | Pod Runtime Inspection

# Task
# In namespace project-tiger:
# 1. Create Pod tigers-reunite with image httpd:2-alpine and labels:
#    pod=container, container=pod
# 2. Find the container runtime container for that Pod
# 3. Write container ID and runtimeType into /opt/course/17/pod-container.txt
# 4. Write container logs into /opt/course/17/pod-container.log

# Note
# - Find the node where the Pod is scheduled.
# - SSH to that node and use crictl there.
