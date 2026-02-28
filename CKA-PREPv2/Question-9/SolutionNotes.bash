cat <<'EOF' > pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: api-contact
  namespace: project-swan
spec:
  serviceAccountName: secret-reader
  containers:
  - name: api-contact
    image: curlimages/curl:8.11.1
    command: ["sh", "-c", "sleep 3600"]
EOF

kubectl apply -f pod.yaml

kubectl -n project-swan exec api-contact -- sh -c '
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
curl --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
  -H "Authorization: Bearer ${TOKEN}" \
  https://kubernetes.default/api/v1/namespaces/project-swan/secrets \
  > /tmp/result.json
'

kubectl -n project-swan exec api-contact -- cat /tmp/result.json > /opt/course/9/result.json
