#!/bin/bash

set -euo pipefail

echo "Fetching test infrastructure manifests"
# these are required to create test infrastructure (currently we use latest)
release_base_url="https://gcsweb.apps.ovirt.org/gcs/kubevirt-prow/devel/nightly/release/kubevirt/kubevirt"
release_date=$(curl -L "${release_base_url}/latest")
release_url="${release_base_url}/${release_date}"

TEMP_DIR=$(mktemp -d /tmp/kubevirt_testing.XXXXXXi)
(
    cd $TEMP_DIR 
        for testinfra_file in $(curl -L "${release_url}/testing/" | grep -oE 'https://[^"]*\.yaml'); do
            wget ${testinfra_file}
        done
)
echo $TEMP_DIR
