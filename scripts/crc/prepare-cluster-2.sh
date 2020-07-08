#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

set -xeuo pipefail

#oc create -f $SCRIPT_DIR/../../resources/project-os-ci.yaml
#oc project os-ci
oc apply -f $SCRIPT_DIR/../../resources/default-cluster-admin.yaml
bash $SCRIPT_DIR/prepare-roles-for-crc.sh
