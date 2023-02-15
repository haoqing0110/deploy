#!/bin/bash
# Create a namespace managed cluster namespace on the hub cluster
export CLUSTER_NAME=cluster1
oc new-project "${CLUSTER_NAME}"
oc label namespace "${CLUSTER_NAME}" cluster.open-cluster-management.io/managedCluster="${CLUSTER_NAME}"

# Create the managed cluster
echo "
    apiVersion: cluster.open-cluster-management.io/v1
    kind: ManagedCluster
    metadata:
      name: ${CLUSTER_NAME}
    spec:
      hubAcceptsClient: true" | kubectl apply -f -

# Create the KlusterletAddonConfig
echo "
apiVersion: agent.open-cluster-management.io/v1
kind: KlusterletAddonConfig
metadata:
  name: ${CLUSTER_NAME}
  namespace: ${CLUSTER_NAME}
spec:
  clusterName: ${CLUSTER_NAME}
  clusterNamespace: ${CLUSTER_NAME}
  applicationManager:
    enabled: true
  certPolicyController:
    enabled: true
  clusterLabels:
    cloud: auto-detect
    vendor: auto-detect
  iamPolicyController:
    enabled: true
  policyController:
    enabled: true
  searchCollector:
    enabled: true
  version: 2.2.0" | kubectl apply -f -

oc get secret "${CLUSTER_NAME}"-import -n "${CLUSTER_NAME}" -o jsonpath={.data.crds\\.yaml} | base64 --decode > klusterlet-crd.yaml
oc get secret "${CLUSTER_NAME}"-import -n "${CLUSTER_NAME}" -o jsonpath={.data.import\\.yaml} | base64 --decode > import.yaml
