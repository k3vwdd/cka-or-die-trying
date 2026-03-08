Question 5 | Kubectl sorting

Create two bash script files that use kubectl sorting:

1. Create the directory /opt/course/5 if it does not already exist.
2. Write a command into /opt/course/5/find_pods.sh to list all Pods in all namespaces sorted by AGE using metadata.creationTimestamp.
3. Write a command into /opt/course/5/find_pods_uid.sh to list all Pods in all namespaces sorted by metadata.uid.
4. The command in /opt/course/5/find_pods.sh should be:
   kubectl get pods -A --sort-by=.metadata.creationTimestamp
5. The command in /opt/course/5/find_pods_uid.sh should be:
   kubectl get pods -A --sort-by=.metadata.uid
