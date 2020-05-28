#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

set -euo pipefail

if [ $(oc get projects --no-headers | grep os-ci | wc -l) -eq 0 ]; then
    oc create -f $SCRIPT_DIR/../resources/project-os-ci.yaml
fi
#oc project os-ci
export openshift_registry=$(oc get route default-route -n openshift-image-registry --template='{{ .spec.host }}')
podman tag kubevirt-test-pr $openshift_registry/default/kubevirt-test-pr
echo $(oc whoami -t) | podman login -u kubeadmin --password-stdin --tls-verify=false $openshift_registry
podman push --tls-verify=false $openshift_registry/default/kubevirt-test-pr

