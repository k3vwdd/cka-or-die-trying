# CKA Practice Lab: Kill Scheduler, Manual Scheduling

# Step 1: Temporarily stop kube-scheduler in a reversible way
# Step 2: Create a Pod named manual-schedule with image httpd:2-alpine and confirm it is created but not scheduled
# Step 3: Manually schedule that Pod onto the controlplane node and confirm it is Running
# Step 4: Start kube-scheduler again and confirm normal scheduling by creating a second Pod named manual-schedule2 with image httpd:2-alpine
# Step 5: Verify manual-schedule2 runs on node01
