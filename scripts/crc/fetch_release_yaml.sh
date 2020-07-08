#!/usr/bin/env bash
set -xeuo pipefail

release_base_url="https://gcsweb.apps.ovirt.org/gcs/kubevirt-prow/devel/nightly/release/kubevirt/kubevirt"
release_date=$(curl -L "${release_base_url}/latest")
release_url="${release_base_url}/${release_date}"
commit=$(curl -L "${release_url}/commit")

export DOCKER_PREFIX='kubevirtnightlybuilds'
DOCKER_TAG="${release_date}_$(echo ${commit} | cut -c 1-9)"
export DOCKER_TAG

temp_dir=$(mktemp --tmpdir -d kubevirt_manifests.XXXXXXXXX) || exit 1

(
    cd ${temp_dir} || exit 1
    mkdir ${release_date} && cd ${release_date} || exit 1
    echo "fetching kubevirt from nightly build"
    wget "${release_url}/kubevirt-operator.yaml"
    wget "${release_url}/kubevirt-cr.yaml"
    wget "${release_url}/commit"

    mkdir "testing" && cd "testing" || exit 1
    echo "fetching test infrastructure"
    for testinfra_file in $(curl -L "${release_url}/testing/" | grep -oE 'https://[^"]*\.yaml'); do
        wget ${testinfra_file}
    done
)
echo "Files downloaded to $temp_dir"