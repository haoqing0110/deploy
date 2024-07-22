#/bin/bash

#Step1 ImageContentSourcePolicy
echo "
apiVersion: operator.openshift.io/v1alpha1
kind: ImageContentSourcePolicy
metadata:
  name: rhacm-repo
spec:
  repositoryDigestMirrors:
  - mirrors:
    - quay.io:443/acm-d
    source: registry.redhat.io/rhacm2
  - mirrors:
    - quay.io:443/acm-d
    source: registry.redhat.io/multicluster-engine
  - mirrors:
    - registry.redhat.io/openshift4/ose-oauth-proxy
    source: registry.access.redhat.com/openshift4/ose-oauth-proxy" | kubectl apply -f -

# Step2 pull_secret
# Replace <USER> and <PASSWORD> with your credentials
oc get secret/pull-secret -n openshift-config --template='{{index .data ".dockerconfigjson" | base64decode}}' >pull_secret.yaml
oc registry login --registry="quay.io:443" --auth-basic="xxx" --to=pull_secret.yaml
oc set data secret/pull-secret -n openshift-config --from-file=.dockerconfigjson=pull_secret.yaml
#rm pull_secret.yaml

#Step3 QUAY_TOKEN
export DOCKER_CONFIG=xxx
export QUAY_TOKEN=$(echo $DOCKER_CONFIG | base64 -d | sed "s/quay\.io/quay\.io:443/g" | base64 -w 0)

#Step4
export COMPOSITE_BUNDLE=true
export DOWNSTREAM=true
export CUSTOM_REGISTRY_REPO="quay.io:443/acm-d"
./multiclusterengine/start.sh
