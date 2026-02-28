kubectl -n project-c13 get pods -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.status.qosClass}{"\n"}{end}'

# Write all BestEffort pod names (one per line)
kubectl -n project-c13 get pods -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.status.qosClass}{"\n"}{end}' \
  | awk '$2=="BestEffort"{print $1}' \
  > /opt/course/4/pods-terminated-first.txt
