#!/bin/bash        
                
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

set -euo pipefail

if oc get deployment registry; then
    oc delete deployment registry
fi
if oc get service docker-registry; then
    oc delete service docker-registry
fi

oc create -f $GH/dhiller/kubevirt/hack/ci/resources/docker-registry.yaml
