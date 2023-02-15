#!/bin/bash
# Change kubconfig to the managed cluster

# Add quay credentials to the managed cluster too
# Replace <USER> and <PASSWORD> with your credentials
oc get secret/pull-secret -n openshift-config --template='{{index .data ".dockerconfigjson" | base64decode}}' >pull_secret.yaml
oc registry login --registry="quay.io:443" --auth-basic="haoqing:Letmein123" --to=pull_secret.yaml
oc set data secret/pull-secret -n openshift-config --from-file=.dockerconfigjson=pull_secret.yaml
rm pull_secret.yaml

# Apply klusterlet-crd
kubectl apply -f klusterlet-crd.yaml

# replace the registry in import.yaml "registry.redhat.io/rhacm2" to "quay.io:443/acm-d"
#sed 's/registry.redhat.io\/rhacm2/quay.io:443\/acm-d/g' import.yaml > import.yaml

# Apply the import.yaml
kubectl apply -f import.yaml

# Validate the pod status on the managed cluster
kubectl get pod -n open-cluster-management-agent
