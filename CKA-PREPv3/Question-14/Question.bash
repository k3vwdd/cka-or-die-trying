Find and record the following cluster information:

1) Number of controlplane nodes
2) Number of worker (non-controlplane) nodes
3) Service CIDR
4) Configured CNI plugin and its config file path
5) Static pod name suffix for pods running on controlplane

Write answers to:
/opt/course/14/cluster-info

Required file format:
1: [ANSWER]
2: [ANSWER]
3: [ANSWER]
4: [ANSWER]
5: [ANSWER]

Expected approach:
- Ensure the output directory exists at /opt/course/14
- Count controlplane nodes using the control-plane node label
- Count total nodes and derive worker count as non-controlplane nodes
- Read the Service CIDR from the kube-apiserver static pod manifest
- Detect the configured CNI plugin from files in /etc/cni/net.d and record both filename and full path
- Determine the static pod suffix for controlplane pods based on the controlplane node name
- Write all answers exactly into /opt/course/14/cluster-info using the required numbered format
