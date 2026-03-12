mkdir -p /opt/course/v4/16
kubectl api-resources --namespaced -o name > /opt/course/v4/16/resources.txt

MAX_NS=""
MAX_COUNT=0
for ns in $(kubectl get ns -o jsonpath='{.items[*].metadata.name}' | tr ' ' '\n' | grep '^project-'); do
  COUNT=$(kubectl -n "$ns" get roles --no-headers 2>/dev/null | wc -l)
  if [ "$COUNT" -gt "$MAX_COUNT" ]; then
    MAX_COUNT="$COUNT"
    MAX_NS="$ns"
  fi
done

echo "$MAX_NS with $MAX_COUNT roles" > /opt/course/v4/16/crowded-namespace.txt
