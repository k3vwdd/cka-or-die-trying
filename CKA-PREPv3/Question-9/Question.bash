#!/bin/bash
# Question 9 | Kill Scheduler, Manual Scheduling

# Temporarily stop kube-scheduler in a reversible way.
#
# Create a Pod named manual-schedule with image httpd:2-alpine and confirm it is created but not scheduled.
#
# Manually schedule that Pod onto the controlplane node and confirm it is Running.
#
# Start kube-scheduler again and confirm normal scheduling by creating a second Pod named manual-schedule2 with image httpd:2-alpine.
#
# Verify manual-schedule2 runs on node01.
