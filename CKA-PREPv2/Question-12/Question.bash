# Question 12 | Deployment on Worker Nodes Pattern

# Task
# In namespace project-tiger:
# 1. Create Deployment deploy-important with 3 replicas
# 2. Deployment and Pods must have label id=very-important
# 3. First container: name=container1 image=nginx:1-alpine
# 4. Second container: name=container2 image=google/pause
# 5. Configure scheduling so only one Pod can run per worker hostname
#    using topologyKey: kubernetes.io/hostname

# Note
# In single-node labs, focus on correct scheduling config in the manifest.
