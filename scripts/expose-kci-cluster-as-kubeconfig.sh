#!/usr/bin/env bash

if [ ! -n "$KUBEVIRT_PROVIDER" ]; then
    echo "KUBEVIRT_PROVIDER not set!"
    exit 1
fi

set -xeuo pipefail

KCI_KUBECONFIG_DIR=/tmp/kcikubeconfig/$KUBEVIRT_PROVIDER
mkdir -p $KCI_KUBECONFIG_DIR

local_ip_address=$(ifconfig | grep -E '^en' -A 1 | grep -oE 'inet [0-9\.]+' | cut -d ' ' -f 2)
if [ ! -n $local_ip_address ]; then
    echo "Failed to determine local ip address!"
    exit 1
fi

cat $(cluster-up/kubeconfig.sh) | sed 's+server: https://127.0.0.1:+server: https://'"$local_ip_address"':+' > $KCI_KUBECONFIG_DIR/.kubeconfig
config_dir=$(echo $(dirname $(cluster-up/kubeconfig.sh)))
cp -f $config_dir/.kubectl $KCI_KUBECONFIG_DIR/kubectl
cp -f $config_dir/.kubectl $KCI_KUBECONFIG_DIR/oc
echo $KCI_KUBECONFIG_DIR 
