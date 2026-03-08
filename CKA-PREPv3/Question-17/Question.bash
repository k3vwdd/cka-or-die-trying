# CKA Practice Lab: Operator, CRDs, RBAC, Kustomize

# Step-by-step Instructions:
#
# 1. The Kustomize config for this Operator lab exists at:
#      /opt/course/17/operator
#    The prod overlay is deployed using:
#      kubectl kustomize /opt/course/17/operator/prod | kubectl apply -f -
#
# 2. Inspect the current operator logs in the operator-prod namespace to determine which required CRDs the operator is being forbidden from listing.
#
# 3. Update the Kustomize base RBAC config so that:
#    - The Role called operator-role includes permissions to list the required CRDs identified from the logs.
#
# 4. Add a new Student resource (Custom Resource; kind: Student) named student4 with any name and description to the base students manifest.
#
# 5. Deploy the updated Kustomize config to the prod overlay using the same deployment command as above.
#
# You are done when:
#    - The operator can successfully list the required CRDs (RBAC issue resolved)
#    - The student4 custom resource exists in the cluster.
