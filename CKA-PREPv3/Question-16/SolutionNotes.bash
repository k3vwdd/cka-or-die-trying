# Ensure output directory exists
mkdir -p /opt/course/16

# Write all namespaced API resources
the command:
kubectl api-resources --namespaced -o name > /opt/course/16/resources.txt

# Find the project-* namespace with highest count of Roles:
MAX_COUNT=0
MAX_NS=""
for ns in $(kubectl get ns -o jsonpath='{.items[*].metadata.name}' | tr ' ' '\n' | grep '^project-'); do
  count=$(kubectl -n "$ns" get roles --no-headers 2>/dev/null | wc -l)
  if [ "$count" -gt "$MAX_COUNT" ]; then
    MAX_COUNT="$count"
    MAX_NS="$ns"
  fi
done

# Write the result:
echo "$MAX_NS with $MAX_COUNT roles" > /opt/course/16/crowded-namespace.txt
