# Question 11 | DaemonSet

# Task
# Create this DaemonSet in namespace project-tiger:
# - name: ds-important
# - labels id=ds-important and uuid=18426a0b-5f59-4e10-923f-c0e078e82462
# - container image: httpd:2-alpine
# - requests: cpu=10m, memory=10Mi
# - toleration for control-plane NoSchedule
