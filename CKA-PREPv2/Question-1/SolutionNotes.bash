# List context names
kubectl --kubeconfig /opt/course/1/kubeconfig config get-contexts -o name > /opt/course/1/contexts

# Print current context
kubectl --kubeconfig /opt/course/1/kubeconfig config current-context > /opt/course/1/current-context

# Decode account-0027 certificate
kubectl --kubeconfig /opt/course/1/kubeconfig config view --raw \
  -o jsonpath="{.users[?(@.name=='account-0027@internal')].user.client-certificate-data}" \
  | base64 -d > /opt/course/1/cert
