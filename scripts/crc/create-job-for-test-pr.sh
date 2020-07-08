#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

set -euo pipefail

if oc get deployment registry; then
    oc delete deployment registry
fi
if oc get service docker-registry; then
    oc delete service docker-registry
fi
if oc get job kubevirt-test-pr; then
    oc delete job kubevirt-test-pr
fi
oc create -f $SCRIPT_DIR/../../resources/testJob.yaml
while [ $(oc describe job kubevirt-test-pr | grep 'Created pod' | wc -l) -eq 0 ]; do
    sleep 1
done
while [ $(oc describe job kubevirt-test-pr | grep 'Created pod' | wc -l) -eq 0 ];do
    sleep 3
done
pod=$(oc describe job kubevirt-test-pr | grep -oE 'Created pod:.*' | grep -oE 'kubevirt-test-pr.*')
oc wait pod $pod --for=condition=ready --timeout=120s
oc logs -f $pod
