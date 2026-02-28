kubectl -n project-hamster create sa processor

kubectl -n project-hamster create role processor \
  --verb=create \
  --resource=secrets \
  --resource=configmaps

kubectl -n project-hamster create rolebinding processor \
  --role=processor \
  --serviceaccount=project-hamster:processor

kubectl -n project-hamster auth can-i create secret \
  --as system:serviceaccount:project-hamster:processor
