Question 2 | Create a Static Pod and Service

1. Create a Static Pod named my-static-pod in Namespace default on the controlplane node.
2. The Static Pod must use image nginx:1-alpine.
3. Configure resource requests for the container as follows:
   - cpu: 10m
   - memory: 20Mi
4. Create a NodePort Service named static-pod-service that exposes this Pod on port 80.
5. Verification requirements:
   - The Service must have exactly one Endpoint.
   - The Pod must be reachable via the controlplane internal IP and the assigned NodePort.
6. Use the static pod manifest path on the controlplane node.
