#!/bin/bash
set -xeuo pipefail

branch=master
if [ "$#" -gt 1 ]; then
    case $1 in
        -b|--branch)
            branch="$2"
            ;;
    esac
fi

configuration_file="$GH/openshift/release/ci-operator/config/kubevirt/kubevirt/kubevirt-kubevirt-${branch}.yaml"
if [ ! -f "$configuration_file" ]; then
    echo "Configuration for branch $branch does not exist: $configuration_file"
fi

SCRIPT_DIR=$(mktemp -d "/tmp/${branch}-XXXXXX")
SHARED_DIR="$SCRIPT_DIR"
yq -r '.tests[0].steps.test[0].commands' "$configuration_file" > "$SCRIPT_DIR/test.sh"
chmod +x "$SCRIPT_DIR/test.sh"
ARTIFACT_DIR="${SCRIPT_DIR}/artifacts"
mkdir -p "${ARTIFACT_DIR}"

cat "$($GH/kubevirt.io/kubevirtci/cluster-up/kubeconfig.sh)" > "$SCRIPT_DIR/kubeconfig"

# shellcheck disable=SC2046
docker run -it --network host -v "$(cd $GH/kubevirt.io/kubevirt && pwd):/go/src/kubevirt/kubevirt:Z" -v "$SCRIPT_DIR:/tmp/scripts:Z" -v "$SHARED_DIR:/tmp/shared:Z" -v "$ARTIFACT_DIR:/tmp/artifacts:Z" --entrypoint "/entrypoint.sh" -e KUBECONFIG=/tmp/shared/kubeconfig -e SHARED_DIR=/tmp/shared -e ARTIFACT_DIR=/tmp/artifacts -e REPO_OWNER=kubevirt -e REPO_NAME=kubevirt -e JOB_NAME= $(echo "$(yq -r '.presets[].env[] | " -e "+.name+"="+.value' /home/dhiller/Projects/github.com/kubevirt.io/project-infra/github/ci/prow/files/jobs/kubevirt/kubevirt/kubevirt-presets.yaml | tr '\n' ' ')")  --rm kubevirt/builder:30-7.0.0-amd64 'cd /go/src/kubevirt/kubevirt && pwd && bash -x /tmp/scripts/test.sh' || (
    #cat "$SCRIPT_DIR/test.sh"
    #ls -la "$SHARED_DIR"
    exit 1
)