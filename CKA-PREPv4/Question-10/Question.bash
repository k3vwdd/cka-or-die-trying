Question 10 | Service Has No Endpoints

Namespace: qv4-10

Service api has no endpoints.
Fix service-to-pod mapping without recreating the deployment.

Validation target:
- Service api should have at least one endpoint
- Curl from debug pod to http://api should return HTTP content
