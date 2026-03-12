Question 4 | Static Pod With HostPath

On controlplane, create a static pod manifest at:
/etc/kubernetes/manifests/controlplane-probe.yaml

Requirements:
1. Pod name: controlplane-probe
2. Image: busybox:1
3. Command: write current date every 5s to /logs/probe.log
4. Use hostPath volume mounted at /logs, backing directory /opt/course/v4/4/logs

Confirm pod is Running in namespace default.
