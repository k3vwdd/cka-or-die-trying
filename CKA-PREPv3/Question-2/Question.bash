# Create a Static Pod and Service
# - Static Pod: my-static-pod, image: nginx:1-alpine
# - Resource requests: cpu 10m, memory 20Mi
# - Node: controlplane
# - Service: NodePort static-pod-service, port 80
# Target: Service should have one endpoint, Pod accessible via controlplane internal IP and NodePort
