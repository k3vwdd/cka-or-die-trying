#!/bin/bash
# Question 4 | Pod Ready if Service is reachable

# In Namespace default:
# - Create a Pod named ready-if-service-ready using image nginx:1-alpine
# - Add a livenessProbe that executes command true
# - Add a readinessProbe that checks reachability of http://service-am-i-ready:80
#   (for example: wget -T2 -O- http://service-am-i-ready:80)
# - Start the Pod and confirm it is not Ready due to the readiness probe
#
# Then:
# - Create a second Pod named am-i-ready with image nginx:1-alpine and label id=cross-server-ready
# - The existing Service service-am-i-ready should select that second Pod as an endpoint
# - Confirm the first Pod transitions to Ready
