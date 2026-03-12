KCFG=/opt/course/v4/2/kubeconfig

kubectl --kubeconfig "$KCFG" config get-contexts -o name > /opt/course/v4/2/contexts
kubectl --kubeconfig "$KCFG" config current-context > /opt/course/v4/2/current-context

CURRENT=$(kubectl --kubeconfig "$KCFG" config current-context)
kubectl --kubeconfig "$KCFG" config view --raw -o jsonpath="{.contexts[?(@.name=='${CURRENT}')].context.cluster}" > /tmp/v4_q2_cluster
CLUSTER_NAME=$(cat /tmp/v4_q2_cluster)
kubectl --kubeconfig "$KCFG" config view --raw -o jsonpath="{.clusters[?(@.name=='${CLUSTER_NAME}')].cluster.server}" > /opt/course/v4/2/current-server
