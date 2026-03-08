#!/bin/bash
cat <<'EOF'
Question 6 | Fix Kubelet

There is an issue on the controlplane node: kubelet is not running.

Tasks:
1. Investigate why kubelet is not running on the controlplane node.
2. Fix kubelet so that it starts successfully.
3. Confirm the controlplane node returns to Ready state.
4. Create a Pod named success in Namespace default using image nginx:1-alpine.
5. Verify the Pod is running.

Notes:
- The node has no taints and can schedule Pods without additional tolerations.
- Use only the controlplane node for this task.
EOF
