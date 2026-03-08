mkdir -p /opt/course/16
kubectl api-resources --namespaced -o name > /opt/course/16/resources.txt

MAX_COUNT=0
MAX_NS=""
for ns in $(kubectl get ns -o jsonpath='{.items[*].metadata.name}' | tr ' ' '\n' | grep '^project-'); do
  count=$(kubectl -n "$ns" get roles --no-headers 2>/dev/null | wc -l)
  if [ "$count" -gt "$MAX_COUNT" ]; then
    MAX_COUNT="$count"
    MAX_NS="$ns"
  fi
done

echo "$MAX_NS with $MAX_COUNT roles" > /opt/course/16/crowded-namespace.txt

cat /opt/course/16/resources.txt
cat /opt/course/16/crowded-namespace.txt
