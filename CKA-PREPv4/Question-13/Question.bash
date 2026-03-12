Question 13 | NetworkPolicy Traffic Restore

Namespace: qv4-13

Traffic from client pod to service app-svc is blocked.
Fix network policy so:

1. Only pods with label role=client can access app-svc on TCP 80
2. app remains denied from other pods
