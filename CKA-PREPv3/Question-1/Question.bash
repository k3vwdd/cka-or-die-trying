Update the existing Deployment workflow in Namespace lima-control so it communicates with cluster-internal endpoints by using correct DNS FQDN values.

Perform the following tasks:

1. Inspect the ConfigMap used by the Deployment in Namespace lima-control.

2. Update the ConfigMap control-config so it contains these exact values:
   - DNS_1: Service kubernetes in Namespace default
   - DNS_2: Headless Service department in Namespace lima-workload
   - DNS_3: Pod section100 in Namespace lima-workload (this must keep working even if the Pod IP changes)
   - DNS_4: A Pod with IP 1.2.3.4 in Namespace kube-system

3. Ensure the Deployment in Namespace lima-control uses the updated ConfigMap values.

4. Restart or otherwise update the Deployment if needed so the running controller Pods load the new ConfigMap values.

5. Verify resolution from inside a controller Pod. You can use nslookup or dig.

Expected DNS values:
- DNS_1=kubernetes.default.svc.cluster.local
- DNS_2=department.lima-workload.svc.cluster.local
- DNS_3=section100.section.lima-workload.svc.cluster.local
- DNS_4=1-2-3-4.kube-system.pod.cluster.local
