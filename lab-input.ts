export type LabInput = {
  id: number;
  question: string;
  fullAnswer: string;
};

export const labInputs: LabInput[] = [
  {
    id: 1,
    question: `The Deployment controller in Namespace lima-control communicates with cluster-internal endpoints by using DNS FQDN values.

Update the ConfigMap used by the Deployment so it contains correct values for:
- DNS_1: Service kubernetes in Namespace default
- DNS_2: Headless Service department in Namespace lima-workload
- DNS_3: Pod section100 in Namespace lima-workload (must keep working if Pod IP changes)
- DNS_4: A Pod with IP 1.2.3.4 in Namespace kube-system

Ensure the Deployment works with the updated values.

You can use nslookup or dig from inside a controller Pod for verification.`,
    fullAnswer: `# Inspect current ConfigMap
kubectl -n lima-control get configmap control-config -o yaml

# Update ConfigMap values
kubectl -n lima-control edit configmap control-config
# Set:
# DNS_1=kubernetes.default.svc.cluster.local
# DNS_2=department.lima-workload.svc.cluster.local
# DNS_3=section100.section.lima-workload.svc.cluster.local
# DNS_4=1-2-3-4.kube-system.pod.cluster.local

# Restart Deployment so it reloads updated ConfigMap values
kubectl -n lima-control rollout restart deployment controller

# Optional verification from a controller pod
POD_NAME=$(kubectl -n lima-control get pods -l app=controller -o jsonpath='{.items[0].metadata.name}')
kubectl -n lima-control exec -it "$POD_NAME" -- nslookup kubernetes.default.svc.cluster.local
kubectl -n lima-control exec -it "$POD_NAME" -- nslookup department.lima-workload.svc.cluster.local
kubectl -n lima-control exec -it "$POD_NAME" -- nslookup section100.section.lima-workload.svc.cluster.local
kubectl -n lima-control exec -it "$POD_NAME" -- nslookup 1-2-3-4.kube-system.pod.cluster.local`,
  },
  {
    id: 2,
    question: `Question 2 | Create a Static Pod and Service

Create a Static Pod named my-static-pod in Namespace default on the controlplane node.
It should use image nginx:1-alpine and have resource requests:
- cpu: 10m
- memory: 20Mi

Create a NodePort Service named static-pod-service that exposes this Pod on port 80.

Verification target:
- The Service should have exactly one Endpoint
- The Pod should be reachable via the controlplane internal IP and the assigned NodePort`,
    fullAnswer: `# 1) Create static pod manifest on controlplane manifest path
cd /etc/kubernetes/manifests
kubectl run my-static-pod --image=nginx:1-alpine -o yaml --dry-run=client > my-static-pod.yaml

# 2) Edit manifest to include required resource requests
# File: /etc/kubernetes/manifests/my-static-pod.yaml
# Required spec shape:
# metadata:
#   name: my-static-pod
#   labels:
#     run: my-static-pod
# spec:
#   containers:
#   - name: my-static-pod
#     image: nginx:1-alpine
#     resources:
#       requests:
#         cpu: 10m
#         memory: 20Mi

# 3) Confirm static pod is running
kubectl get pods -n default | grep my-static-pod

# 4) Expose static pod via NodePort service on port 80
POD_NAME=$(kubectl get pod -n default -l run=my-static-pod -o jsonpath='{.items[0].metadata.name}')
kubectl expose pod "$POD_NAME" --name static-pod-service --type=NodePort --port=80

# 5) Validate service and endpoint
kubectl get svc static-pod-service -n default
kubectl get endpointslice -n default -l kubernetes.io/service-name=static-pod-service

# 6) Validate external reachability using controlplane internal IP + nodePort
NODE_PORT=$(kubectl get svc static-pod-service -n default -o jsonpath='{.spec.ports[0].nodePort}')
CONTROLPLANE_NODE=$(kubectl get node -l node-role.kubernetes.io/control-plane -o jsonpath='{.items[0].metadata.name}')
NODE_IP=$(kubectl get node "$CONTROLPLANE_NODE" -o jsonpath='{.status.addresses[?(@.type=="InternalIP")].address}')
curl "\${NODE_IP}:\${NODE_PORT}"`,
  },
  {
    id: 3,
    question: `Question 3 | Kubelet client/server cert info

Node node01 has been added to the cluster using kubeadm and TLS bootstrapping.

Find the Issuer and Extended Key Usage values on node01 for:
- Kubelet Client Certificate (used for outgoing connections to kube-apiserver)
- Kubelet Server Certificate (used for incoming connections from kube-apiserver)

Write the information into:
/opt/course/3/certificate-info.txt`,
    fullAnswer: `# 1) On node01, inspect kubelet PKI location
ls -la /var/lib/kubelet/pki

# 2) Extract issuer + extended key usage for kubelet client certificate
openssl x509 -noout -text -in /var/lib/kubelet/pki/kubelet-client-current.pem | grep Issuer
openssl x509 -noout -text -in /var/lib/kubelet/pki/kubelet-client-current.pem | grep "Extended Key Usage" -A1

# 3) Extract issuer + extended key usage for kubelet server certificate
openssl x509 -noout -text -in /var/lib/kubelet/pki/kubelet.crt | grep Issuer
openssl x509 -noout -text -in /var/lib/kubelet/pki/kubelet.crt | grep "Extended Key Usage" -A1

# 4) Write required values to output file
cat <<'EOF' > /opt/course/3/certificate-info.txt
Issuer: <client-cert-issuer>
X509v3 Extended Key Usage: <client-cert-eku>
Issuer: <server-cert-issuer>
X509v3 Extended Key Usage: <server-cert-eku>
EOF

# 5) Replace placeholders with actual extracted values from openssl output
# Example EKU values:
# - TLS Web Client Authentication
# - TLS Web Server Authentication

# 6) Verify output file exists and has content
cat /opt/course/3/certificate-info.txt`,
  },
  {
    id: 4,
    question: `Question 4 | Pod Ready if Service is reachable

In Namespace default:
- Create a Pod named ready-if-service-ready using image nginx:1-alpine
- Add a livenessProbe that executes command true
- Add a readinessProbe that checks reachability of http://service-am-i-ready:80
  (for example: wget -T2 -O- http://service-am-i-ready:80)
- Start the Pod and confirm it is not Ready due to the readiness probe

Then:
- Create a second Pod named am-i-ready with image nginx:1-alpine and label id=cross-server-ready
- The existing Service service-am-i-ready should select that second Pod as an endpoint
- Confirm the first Pod transitions to Ready`,
    fullAnswer: `# 1) Create manifest for first Pod
kubectl run ready-if-service-ready --image=nginx:1-alpine --dry-run=client -o yaml > /tmp/ready-if-service-ready.yaml

# 2) Edit manifest to add probes and then create Pod
# File: /tmp/ready-if-service-ready.yaml
# Under spec.containers[0], set:
# livenessProbe:
#   exec:
#     command:
#     - "true"
# readinessProbe:
#   exec:
#     command:
#     - sh
#     - -c
#     - wget -T2 -O- http://service-am-i-ready:80
kubectl apply -f /tmp/ready-if-service-ready.yaml

# 3) Confirm first Pod is not Ready initially
kubectl get pod ready-if-service-ready -n default
kubectl describe pod ready-if-service-ready -n default

# 4) Create second Pod with required label so service selects it
kubectl run am-i-ready --image=nginx:1-alpine --labels=id=cross-server-ready -n default

# 5) Verify service now has endpoint(s)
kubectl get svc service-am-i-ready -n default
kubectl get endpointslice -n default -l kubernetes.io/service-name=service-am-i-ready

# 6) Re-check first Pod readiness
kubectl get pod ready-if-service-ready -n default`,
  },
  {
    id: 5,
    question: `Question 5 | Kubectl sorting

Create two bash script files that use kubectl sorting:
- Write a command into /opt/course/5/find_pods.sh to list all Pods in all namespaces sorted by AGE (metadata.creationTimestamp)
- Write a command into /opt/course/5/find_pods_uid.sh to list all Pods in all namespaces sorted by metadata.uid`,
    fullAnswer: `# 1) Ensure target directory exists
mkdir -p /opt/course/5

# 2) Create script for sorting pods by creation timestamp (AGE)
cat <<'EOF' > /opt/course/5/find_pods.sh
kubectl get pods -A --sort-by=.metadata.creationTimestamp
EOF

# 3) Create script for sorting pods by UID
cat <<'EOF' > /opt/course/5/find_pods_uid.sh
kubectl get pods -A --sort-by=.metadata.uid
EOF

# 4) Optional: verify script contents
cat /opt/course/5/find_pods.sh
cat /opt/course/5/find_pods_uid.sh

# 5) Optional: execute scripts
sh /opt/course/5/find_pods.sh
sh /opt/course/5/find_pods_uid.sh`,
  },
  {
    id: 6,
    question: `Question 6 | Fix Kubelet

There is an issue on the controlplane node: kubelet is not running.

Fix kubelet and confirm the node returns to Ready state.

Create a Pod named success in Namespace default using image nginx:1-alpine.

Note:
- The node has no taints and can schedule Pods without additional tolerations.`,
    fullAnswer: `# 1) Confirm control plane API/node is unavailable from this node
kubectl get nodes

# 2) Check kubelet service state
systemctl status kubelet

# 3) Try starting kubelet and inspect error state
systemctl start kubelet
systemctl status kubelet

# 4) Confirm kubelet binary path issue
whereis kubelet
# Expected binary path includes /usr/bin/kubelet

# 5) Fix kubelet systemd drop-in to point ExecStart to /usr/bin/kubelet
# File: /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf
# Ensure final command uses:
# ExecStart=/usr/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_KUBEADM_ARGS $KUBELET_EXTRA_ARGS

# 6) Reload systemd and restart kubelet
systemctl daemon-reload
systemctl restart kubelet
systemctl status kubelet

# 7) Confirm cluster control-plane components recover and node becomes Ready
kubectl get nodes

# 8) Create requested pod
kubectl run success --image=nginx:1-alpine -n default

# 9) Verify pod is running
kubectl get pod success -n default -o wide`,
  },
  {
    id: 7,
    question: `Question 7 | Etcd Operations

Perform the following etcd operations:
- Run etcd --version and store the output at /opt/course/7/etcd-version
- Create an etcd snapshot and save it at /opt/course/7/etcd-snapshot.db`,
    fullAnswer: `# 1) Ensure output directory exists
mkdir -p /opt/course/7

# 2) Capture etcd version output
# In kubeadm clusters, etcd often runs as a static pod; execute etcd inside that pod
ETCD_POD=$(kubectl -n kube-system get pods -l component=etcd -o jsonpath='{.items[0].metadata.name}')
kubectl -n kube-system exec "$ETCD_POD" -- etcd --version > /opt/course/7/etcd-version

# 3) Create etcd snapshot using local control-plane certs
ETCDCTL_API=3 etcdctl snapshot save /opt/course/7/etcd-snapshot.db \
  --cacert /etc/kubernetes/pki/etcd/ca.crt \
  --cert /etc/kubernetes/pki/etcd/server.crt \
  --key /etc/kubernetes/pki/etcd/server.key

# 4) Verify both outputs exist
ls -l /opt/course/7/etcd-version /opt/course/7/etcd-snapshot.db`,
  },
  {
    id: 8,
    question: `Question 8 | Get Controlplane Information

Determine how these controlplane components are started/installed:
- kubelet
- kube-apiserver
- kube-scheduler
- kube-controller-manager
- etcd

Also determine the DNS application name and how it is started/installed.

Write findings to:
/opt/course/8/controlplane-components.txt

Required output format:
kubelet: [TYPE]
kube-apiserver: [TYPE]
kube-scheduler: [TYPE]
kube-controller-manager: [TYPE]
etcd: [TYPE]
dns: [TYPE] [NAME]

Allowed [TYPE] values:
- not-installed
- process
- static-pod
- pod`,
    fullAnswer: `# 1) Ensure output directory exists
mkdir -p /opt/course/8

# 2) Identify kubelet startup type
systemctl status kubelet
# If running as host system service/process, classify as: process

# 3) Identify controlplane static pod manifests
ls -1 /etc/kubernetes/manifests
# Presence of kube-apiserver.yaml, kube-scheduler.yaml, kube-controller-manager.yaml, etcd.yaml indicates static-pod

# 4) Confirm running controlplane pods
kubectl -n kube-system get pods -o wide

# 5) Identify DNS app and workload type
kubectl -n kube-system get deploy,ds
# Typically DNS app is coredns and runs as pod(s) managed by Deployment

# 6) Write final findings in required format
cat <<'EOF' > /opt/course/8/controlplane-components.txt
kubelet: process
kube-apiserver: static-pod
kube-scheduler: static-pod
kube-controller-manager: static-pod
etcd: static-pod
dns: pod coredns
EOF

# 7) Verify output
cat /opt/course/8/controlplane-components.txt`,
  },
  {
    id: 9,
    question: `Question 9 | Kill Scheduler, Manual Scheduling

Temporarily stop kube-scheduler in a reversible way.

Create a Pod named manual-schedule with image httpd:2-alpine and confirm it is created but not scheduled.

Manually schedule that Pod onto the controlplane node and confirm it is Running.

Start kube-scheduler again and confirm normal scheduling by creating a second Pod named manual-schedule2 with image httpd:2-alpine.

Verify manual-schedule2 runs on node01.`,
    fullAnswer: `# 1) Stop kube-scheduler temporarily (static pod)
mv /etc/kubernetes/manifests/kube-scheduler.yaml /etc/kubernetes/

# 2) Confirm scheduler pod is gone
kubectl -n kube-system get pods | grep kube-scheduler

# 3) Create pod that should remain Pending without scheduler
kubectl run manual-schedule --image=httpd:2-alpine -n default
kubectl get pod manual-schedule -n default -o wide

# 4) Manually schedule pod by setting spec.nodeName to controlplane
kubectl get pod manual-schedule -n default -o yaml > /tmp/manual-schedule.yaml
# Edit /tmp/manual-schedule.yaml and set:
# spec:
#   nodeName: controlplane
kubectl replace --force -f /tmp/manual-schedule.yaml
kubectl get pod manual-schedule -n default -o wide

# 5) Start scheduler again
mv /etc/kubernetes/kube-scheduler.yaml /etc/kubernetes/manifests/
kubectl -n kube-system get pods | grep kube-scheduler

# 6) Create second pod and verify scheduler places it on node01
kubectl run manual-schedule2 --image=httpd:2-alpine -n default
kubectl get pod manual-schedule2 -n default -o wide`,
  },
  {
    id: 10,
    question: `Question 10 | PV PVC Dynamic Provisioning

There is a backup Job that needs to be adjusted to store backups on a PVC.

Create a StorageClass named local-backup with:
- provisioner: rancher.io/local-path
- volumeBindingMode: WaitForFirstConsumer
- reclaimPolicy: Retain (PV must be retained after bound PVC deletion)

Adjust /opt/course/10/backup.yaml to use a PVC requesting 50Mi with StorageClass local-backup.

Deploy changes and verify:
- Job completes once
- PVC is bound to a newly created PV

Note:
- To re-run a Job, delete it and create/apply it again.`,
    fullAnswer: `# 1) Check existing storage classes (optional)
kubectl get storageclass

# 2) Create StorageClass local-backup
cat <<'EOF' > /tmp/local-backup-sc.yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-backup
provisioner: rancher.io/local-path
reclaimPolicy: Retain
volumeBindingMode: WaitForFirstConsumer
EOF
kubectl apply -f /tmp/local-backup-sc.yaml

# 3) Edit /opt/course/10/backup.yaml
# File: /opt/course/10/backup.yaml
# Current Job uses:
# volumes:
# - name: backup
#   emptyDir: {}
#
# Add a PVC manifest before the Job:
# apiVersion: v1
# kind: PersistentVolumeClaim
# metadata:
#   name: backup-pvc
#   namespace: project-bern
# spec:
#   accessModes: [ReadWriteOnce]
#   resources:
#     requests:
#       storage: 50Mi
#   storageClassName: local-backup
#
# In Job template, replace emptyDir with:
# volumes:
# - name: backup
#   persistentVolumeClaim:
#     claimName: backup-pvc

# 4) Recreate Job so updated pod template runs with PVC
kubectl -n project-bern delete job backup --ignore-not-found
kubectl apply -f /opt/course/10/backup.yaml

# 5) Verify Job completion and PVC/PV binding
kubectl -n project-bern get job backup
kubectl -n project-bern get pods -l job-name=backup
kubectl -n project-bern get pvc backup-pvc
kubectl get pv

# 6) Optional: re-run Job if needed
kubectl -n project-bern delete job backup
kubectl apply -f /opt/course/10/backup.yaml`,
  },
  {
    id: 11,
    question: `Question 11 | Create Secret and mount into Pod

In Namespace secret:
- Create Pod secret-pod using image busybox:1 and keep it running (for example sleep 1d)
- Create the existing Secret from /opt/course/11/secret1.yaml and mount it read-only at /tmp/secret1 in the Pod
- Create Secret secret2 with keys user=user1 and pass=1234
- Expose secret2 values in the container as environment variables APP_USER and APP_PASS`,
    fullAnswer: `# 1) Create namespace
kubectl create namespace secret

# 2) Create secret1 from provided manifest in the correct namespace
kubectl apply -f /opt/course/11/secret1.yaml -n secret

# 3) Create secret2 from literals
kubectl -n secret create secret generic secret2 \
  --from-literal=user=user1 \
  --from-literal=pass=1234

# 4) Create pod manifest and add secret volume + env refs
kubectl -n secret run secret-pod --image=busybox:1 --dry-run=client -o yaml -- sh -c "sleep 1d" > /tmp/secret-pod.yaml

# Edit /tmp/secret-pod.yaml and ensure:
# - spec.containers[0].env includes:
#   - name: APP_USER
#     valueFrom.secretKeyRef.name: secret2
#     valueFrom.secretKeyRef.key: user
#   - name: APP_PASS
#     valueFrom.secretKeyRef.name: secret2
#     valueFrom.secretKeyRef.key: pass
# - spec.volumes includes secret volume from secret1
# - spec.containers[0].volumeMounts mounts that volume at /tmp/secret1 with readOnly: true

# 5) Apply pod
kubectl apply -f /tmp/secret-pod.yaml

# 6) Verify env vars and mounted secret files
kubectl -n secret exec secret-pod -- env | grep APP_
kubectl -n secret exec secret-pod -- ls -la /tmp/secret1`,
  },
  {
    id: 12,
    question: `Question 12 | Schedule Pod on Controlplane Nodes

In Namespace default, create a Pod with:
- Pod name: pod1
- Image: httpd:2-alpine
- Container name: pod1-container

The Pod must run only on controlplane nodes.
Do not add labels to nodes.`,
    fullAnswer: `# 1) Generate pod manifest template
kubectl run pod1 --image=httpd:2-alpine --dry-run=client -o yaml > /tmp/pod1.yaml

# 2) Edit manifest to satisfy constraints
# File: /tmp/pod1.yaml
# Ensure container name is pod1-container
# Add toleration for control-plane taint:
# tolerations:
# - key: node-role.kubernetes.io/control-plane
#   effect: NoSchedule
# Add node selector so it schedules only to controlplane nodes:
# nodeSelector:
#   node-role.kubernetes.io/control-plane: ""

# 3) Apply pod manifest
kubectl apply -f /tmp/pod1.yaml

# 4) Verify pod is running on controlplane node
kubectl get pod pod1 -n default -o wide`,
  },
  {
    id: 13,
    question: `Question 13 | Multi Containers and Pod shared Volume

Create a Pod named multi-container-playground in Namespace default with multiple containers.

Requirements:
- Use a shared non-persistent volume mounted in each container (not shared with other Pods)
- Container c1: image nginx:1-alpine, expose node name as env var MY_NODE_NAME
- Container c2: image busybox:1, write current date every second to shared file date.log
- Container c3: image busybox:1, stream date.log from shared volume to stdout

Verify by checking logs of container c3.`,
    fullAnswer: `# 1) Create base pod manifest
kubectl run multi-container-playground --image=nginx:1-alpine --dry-run=client -o yaml > /tmp/multi-container-playground.yaml

# 2) Edit manifest to add multi-container setup and shared volume
# File: /tmp/multi-container-playground.yaml
# - Rename first container to c1 (image nginx:1-alpine)
# - Add env on c1:
#   MY_NODE_NAME from fieldRef: spec.nodeName
# - Add c2 (busybox:1) with command:
#   sh -c "while true; do date >> /vol/date.log; sleep 1; done"
# - Add c3 (busybox:1) with command:
#   sh -c "tail -f /vol/date.log"
# - Add shared volume:
#   volumes:
#   - name: vol
#     emptyDir: {}
# - Mount /vol in all three containers

# 3) Apply pod
kubectl apply -f /tmp/multi-container-playground.yaml

# 4) Verify pod and container behavior
kubectl get pod multi-container-playground -n default
kubectl exec -n default multi-container-playground -c c1 -- env | grep MY_NODE_NAME
kubectl logs -n default multi-container-playground -c c3`,
  },
  {
    id: 14,
    question: `Question 14 | Find out Cluster Information

Find and record the following cluster information:
1) Number of controlplane nodes
2) Number of worker (non-controlplane) nodes
3) Service CIDR
4) Configured CNI plugin and its config file path
5) Static pod name suffix for pods running on controlplane

Write answers to:
/opt/course/14/cluster-info

Required file format:
1: [ANSWER]
2: [ANSWER]
3: [ANSWER]
4: [ANSWER]
5: [ANSWER]`,
    fullAnswer: `# 1) Ensure output directory exists
mkdir -p /opt/course/14

# 2) Count controlplane and worker nodes
CONTROLPLANE_COUNT=$(kubectl get nodes -l node-role.kubernetes.io/control-plane --no-headers 2>/dev/null | wc -l)
TOTAL_NODES=$(kubectl get nodes --no-headers | wc -l)
WORKER_COUNT=$((TOTAL_NODES - CONTROLPLANE_COUNT))

# 3) Get Service CIDR from kube-apiserver static pod manifest
SERVICE_CIDR=$(grep -oP '(?<=--service-cluster-ip-range=)\S+' /etc/kubernetes/manifests/kube-apiserver.yaml)

# 4) Detect CNI plugin file from /etc/cni/net.d
CNI_FILE=$(ls /etc/cni/net.d/*.conf /etc/cni/net.d/*.conflist 2>/dev/null | grep -v podman | head -n 1)
CNI_NAME=$(basename "$CNI_FILE")

# 5) Determine static pod suffix on controlplane (hostname based)
CONTROLPLANE_NODE=$(kubectl get node -l node-role.kubernetes.io/control-plane -o jsonpath='{.items[0].metadata.name}')
STATIC_POD_SUFFIX="-\${CONTROLPLANE_NODE}"

# 6) Write results in required format
cat <<EOF > /opt/course/14/cluster-info
1: \${CONTROLPLANE_COUNT}
2: \${WORKER_COUNT}
3: \${SERVICE_CIDR}
4: \${CNI_NAME}, \${CNI_FILE}
5: \${STATIC_POD_SUFFIX}
EOF

# 7) Verify output
cat /opt/course/14/cluster-info`,
  },
  {
    id: 15,
    question: `Question 15 | Cluster Event Logging

Complete the following tasks:
- Write a kubectl command into /opt/course/15/cluster_events.sh that lists latest cluster-wide events sorted by metadata.creationTimestamp
- Delete the kube-proxy Pod and write the related events to /opt/course/15/pod_kill.log
- Manually kill the kube-proxy container via container runtime and write resulting events to /opt/course/15/container_kill.log`,
    fullAnswer: `# 1) Ensure target directory exists
mkdir -p /opt/course/15

# 2) Create script for sorted cluster-wide events
cat <<'EOF' > /opt/course/15/cluster_events.sh
kubectl get events -A --sort-by=.metadata.creationTimestamp
EOF

# 3) Identify and delete kube-proxy pod
KUBE_PROXY_POD=$(kubectl -n kube-system get pods -l k8s-app=kube-proxy -o jsonpath='{.items[0].metadata.name}')
kubectl -n kube-system delete pod "$KUBE_PROXY_POD"

# 4) Capture relevant events after pod deletion
kubectl get events -A --sort-by=.metadata.creationTimestamp > /opt/course/15/pod_kill.log

# 5) Find kube-proxy container ID and force-remove it
KUBE_PROXY_CONTAINER_ID=$(crictl ps | awk '/kube-proxy/ {print $1; exit}')
crictl rm --force "$KUBE_PROXY_CONTAINER_ID"

# 6) Capture relevant events after container kill
kubectl get events -A --sort-by=.metadata.creationTimestamp > /opt/course/15/container_kill.log

# 7) Optional quick checks
sh /opt/course/15/cluster_events.sh
ls -l /opt/course/15/pod_kill.log /opt/course/15/container_kill.log`,
  },
  {
    id: 16,
    question: `Question 16 | Namespaces and API Resources

Write all namespaced Kubernetes resource names into:
/opt/course/16/resources.txt

Then find the project-* namespace that has the highest number of Roles and write:
- namespace name
- number of roles
into:
/opt/course/16/crowded-namespace.txt`,
    fullAnswer: `# 1) Ensure output directory exists
mkdir -p /opt/course/16

# 2) Write all namespaced API resources
kubectl api-resources --namespaced -o name > /opt/course/16/resources.txt

# 3) Find project-* namespace with highest count of Roles
MAX_COUNT=0
MAX_NS=""
for ns in $(kubectl get ns -o jsonpath='{.items[*].metadata.name}' | tr ' ' '\n' | grep '^project-'); do
  count=$(kubectl -n "$ns" get roles --no-headers 2>/dev/null | wc -l)
  if [ "$count" -gt "$MAX_COUNT" ]; then
    MAX_COUNT="$count"
    MAX_NS="$ns"
  fi
done

# 4) Write result
echo "$MAX_NS with $MAX_COUNT roles" > /opt/course/16/crowded-namespace.txt

# 5) Optional verify
cat /opt/course/16/resources.txt
cat /opt/course/16/crowded-namespace.txt`,
  },
  {
    id: 17,
    question: `Question 17 | Operator, CRDs, RBAC, Kustomize

Kustomize config exists at /opt/course/17/operator and is deployed via:
kubectl kustomize /opt/course/17/operator/prod | kubectl apply -f -

Update the Kustomize base config so that:
- Operator Role operator-role has permission to list required CRDs (determine from operator logs)
- Add a new Student resource named student4 with any name and description

Deploy updated Kustomize config to prod.`,
    fullAnswer: `# 1) Inspect current operator logs to find forbidden resources
kubectl -n operator-prod get pods
OP_POD=$(kubectl -n operator-prod get pods -l app=operator -o jsonpath='{.items[0].metadata.name}')
kubectl -n operator-prod logs "$OP_POD"

# 2) Update base RBAC role to allow listing required CRDs
# File: /opt/course/17/operator/base/rbac.yaml
# In Role operator-role, ensure rules include:
# apiGroups: ["education.killer.sh"]
# resources: ["students", "classes"]
# verbs: ["list"]

# 3) Add student4 custom resource in base students manifest
# File: /opt/course/17/operator/base/students.yaml
# Add a new Student object:
# apiVersion: education.killer.sh/v1
# kind: Student
# metadata:
#   name: student4
# spec:
#   name: Any Name
#   description: Any Description

# 4) Deploy updated prod overlay
kubectl kustomize /opt/course/17/operator/prod | kubectl apply -f -

# 5) Verify RBAC issue is resolved and student4 exists
kubectl -n operator-prod logs "$OP_POD"
kubectl -n operator-prod get students`,
  },
];
