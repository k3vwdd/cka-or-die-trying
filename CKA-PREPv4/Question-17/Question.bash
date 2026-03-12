Question 17 | End-to-End Networking Incident

Namespace: qv4-17

The app stack has multiple issues.
Fix the environment so that tester pod can access http://app-svc successfully.

Requirements:
1. app deployment must have 2 ready replicas
2. service app-svc must route to app pods
3. network policy must still block non-tester pods from app pods
