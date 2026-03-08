# In the Namespace default:
# 1. Create a Pod named ready-if-service-ready using image nginx:1-alpine.
# 2. Add a livenessProbe to this Pod that executes the command 'true'.
# 3. Add a readinessProbe to this Pod that checks reachability of http://service-am-i-ready:80 (e.g., by running: wget -T2 -O- http://service-am-i-ready:80).
# 4. Start the Pod and confirm it is NOT Ready (the readiness probe should fail).
#
# Then:
# 5. Create a second Pod named am-i-ready with image nginx:1-alpine and label id=cross-server-ready.
# 6. The existing Service service-am-i-ready should select this second Pod as an endpoint.
# 7. Confirm the first Pod transitions from Not Ready to Ready, as the readiness probe should now pass.
