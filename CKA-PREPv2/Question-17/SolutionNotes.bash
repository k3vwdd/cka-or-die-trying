kubectl -n project-tiger run tigers-reunite --image=httpd:2-alpine --labels "pod=container,container=pod"

kubectl -n project-tiger wait --for=condition=Ready pod/tigers-reunite --timeout=120s

NODE=$(kubectl -n project-tiger get pod tigers-reunite -o jsonpath='{.spec.nodeName}')

# From control plane, SSH into the target node and run:
# sudo -i
# CID=$(crictl ps | awk '/tigers-reunite/{print $1; exit}')
# RT=$(crictl inspect "$CID" | grep -m1 '"runtimeType"' | awk -F '"' '{print $4}')
# echo "$CID $RT" > /opt/course/17/pod-container.txt
# crictl logs "$CID" > /opt/course/17/pod-container.log

echo "Pod tigers-reunite is on node: ${NODE}"
