#!/bin/bash
set -e

mkdir -p /opt/course/10

cat <<'EOF' > /opt/course/10/backup.yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: backup
  namespace: project-bern
spec:
  template:
    spec:
      restartPolicy: Never
      containers:
      - name: backup
        image: busybox
        command: ["sh", "-c", "echo backup > /backup/data && sleep 1"]
        volumeMounts:
        - name: backup
          mountPath: /backup
      volumes:
      - name: backup
        emptyDir: {}
EOF
