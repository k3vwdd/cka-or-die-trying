# Update the DNS values in the configuration for a controller Deployment
#
# 1. Inspect the current ConfigMap used by the Deployment in the lima-control namespace.
# 2. Update the ConfigMap so it has the following entries:
#    - DNS_1: FQDN for Service "kubernetes" in Namespace "default"
#    - DNS_2: FQDN for Headless Service "department" in Namespace "lima-workload"
#    - DNS_3: FQDN for Pod "section100" in Namespace "lima-workload" (should keep working if the Pod IP changes)
#    - DNS_4: FQDN for a Pod with IP 1.2.3.4 in Namespace "kube-system"
# 3. Make sure the controller Deployment in lima-control works with the updated ConfigMap.
# 4. You can use nslookup or dig from inside a controller Pod to verify each DNS name resolves correctly.
