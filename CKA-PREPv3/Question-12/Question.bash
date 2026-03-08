#!/bin/bash
# Question 12 | Schedule Pod on Controlplane Nodes

cat <<'EOF'
In Namespace default, create a Pod with:
- Pod name: pod1
- Image: httpd:2-alpine
- Container name: pod1-container

The Pod must run only on controlplane nodes.
Do not add labels to nodes.
EOF
