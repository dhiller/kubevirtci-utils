#!/bin/bash

set -euo pipefail

TMP_DIR=$(mktemp -d)
trap 'rm -rf ${TMP_DIR}' EXIT SIGINT SIGTERM

cd $TMP_DIR
release_base_url="https://gcsweb.apps.ovirt.org/gcs/kubevirt-prow/devel/nightly/release/kubevirt/kubevirt"
release_date=$(curl -L "${release_base_url}/latest")
release_url="${release_base_url}/${release_date}"
commit=$(curl -L "${release_url}/commit")

export DOCKER_PREFIX='kubevirtnightlybuilds'
DOCKER_TAG="${release_date}_$(echo ${commit} | cut -c 1-9)"
export DOCKER_TAG

echo "Deleting test infrastructure"
for testinfra_file in $(curl -L "${release_url}/testing/" | grep -oE 'https://[^"]*\.yaml'); do
    kubectl delete -f ${testinfra_file}
done

echo "Deleting kubevirt from nightly build"
kubectl delete -f "${release_url}/kubevirt-cr.yaml"
kubectl delete -f "${release_url}/kubevirt-operator.yaml"
