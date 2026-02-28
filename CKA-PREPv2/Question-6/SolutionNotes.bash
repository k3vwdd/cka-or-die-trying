cat <<'EOF' > pv.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: safari-pv
spec:
  capacity:
    storage: 2Gi
  accessModes:
  - ReadWriteOnce
  hostPath:
    path: /Volumes/Data
EOF
kubectl apply -f pv.yaml

cat <<'EOF' > pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: safari-pvc
  namespace: project-t230
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
EOF
kubectl apply -f pvc.yaml

cat <<'EOF' > deploy.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: safari
  namespace: project-t230
spec:
  replicas: 1
  selector:
    matchLabels:
      app: safari
  template:
    metadata:
      labels:
        app: safari
    spec:
      volumes:
      - name: data
        persistentVolumeClaim:
          claimName: safari-pvc
      containers:
      - name: safari
        image: httpd:2-alpine
        volumeMounts:
        - name: data
          mountPath: /tmp/safari-data
EOF
kubectl apply -f deploy.yaml
