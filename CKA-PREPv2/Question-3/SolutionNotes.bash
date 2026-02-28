kubectl -n project-h800 get sts
kubectl -n project-h800 scale sts o3db --replicas=1
kubectl -n project-h800 get sts o3db
