# Question 15 | NetworkPolicy Egress Restriction

# Task
# Create NetworkPolicy np-backend in namespace project-snake.
# It should allow pods with label app=backend to only:
# 1. Connect to pods app=db1 on TCP port 1111
# 2. Connect to pods app=db2 on TCP port 2222

# Use app labels in the policy.
