#!/bin/bash

set -euo pipefail

OC_DL_DIR=$(mktemp -d)
(
    cd $OC_DL_DIR
    curl https://mirror.openshift.com/pub/openshift-v4/clients/oc/4.4/linux/oc.tar.gz | tar -C . -xzf -
    chmod +x oc
    ln -s oc kubectl
) || exit 1
echo "$OC_DL_DIR/oc"
