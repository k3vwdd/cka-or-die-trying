#!/bin/bash
set -e

# Ensure target directory exists
mkdir -p /opt/course/15

# Clean up files if the lab is being set up again
rm -f /opt/course/15/cluster_events.sh /opt/course/15/pod_kill.log /opt/course/15/container_kill.log

# (Optional) Ensure 'crictl' is installed, otherwise add a TODO notice
type crictl >/dev/null 2>&1 || echo "TODO: Install crictl on this system."
