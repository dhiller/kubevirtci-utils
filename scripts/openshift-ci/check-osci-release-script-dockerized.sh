#!/bin/bash
set -xeuo pipefail

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
branch=master
variant=''
while [ "$#" -gt 1 ]; do
    case $1 in
        -b|--branch)
            branch="$2"
            shift; shift;
            ;;
        -v|--variant)
            variant="__$2"
            shift; shift;
            ;;
        *)
            echo "Unexpected arguments: $*"
            exit 1
            ;;
    esac
done

configuration_file="$GH/openshift/release/ci-operator/config/kubevirt/kubevirt/kubevirt-kubevirt-${branch}${variant}.yaml"
if [ ! -f "$configuration_file" ]; then
    echo "Configuration for branch $branch does not exist: $configuration_file"
    exit 1
fi

SCRIPT_DIR=$(mktemp -d "/tmp/${branch}-XXXXXX")
SHARED_DIR="$SCRIPT_DIR"

cp "$(bash "$BASE_DIR/download-oc.sh")" "$SHARED_DIR"
( cd "$SHARED_DIR"; ln -s oc kubectl ) || exit 1

echo "#!/bin/bash" > "$SCRIPT_DIR/test.sh"
yq -r '.tests[0].steps.test[0].commands' "$configuration_file" >> "$SCRIPT_DIR/test.sh"
if [ "$(cat "$SCRIPT_DIR/test.sh")" == 'null' ]; then
    yq -r '.tests[0].commands' "$configuration_file" > "$SCRIPT_DIR/test.sh"
fi
chmod +x "$SCRIPT_DIR/test.sh"
ARTIFACT_DIR="${SCRIPT_DIR}/artifacts"
mkdir -p "${ARTIFACT_DIR}"

cat "$KUBECONFIG" > "$SCRIPT_DIR/kubeconfig"

BASE_IMAGE="registry.svc.ci.openshift.org/$(yq -r '.build_root.image_stream_tag | .namespace+"/"+.name+":"+.tag' "$configuration_file")"
docker pull "$BASE_IMAGE"
TEST_IMAGE="$BASE_IMAGE"
set +e
TEST_IMAGE_DOCKERFILE="$(yq -r '.images[0].dockerfile_path' "$configuration_file")"
set -e
if [ -n "$TEST_IMAGE_DOCKERFILE" ]; then
    TEST_IMAGE="openshift-ci/test-${branch}${variant}"
    docker build -t "$TEST_IMAGE" -f "$TEST_IMAGE_DOCKERFILE" .
fi

docker run -it --network host \
    -v "$(cd "$GH/kubevirt.io/kubevirt" && pwd):/go/src/kubevirt/kubevirt:Z" \
    -v "$SCRIPT_DIR:/tmp/scripts:Z" \
    -v "$SHARED_DIR:/tmp/shared:Z" \
    -v "$ARTIFACT_DIR:/tmp/artifacts:Z" \
    --entrypoint "/entrypoint.sh" \
    -e KUBECONFIG=/tmp/shared/kubeconfig \
    -e SHARED_DIR=/tmp/shared \
    -e ARTIFACTS=/tmp/artifacts \
    -e ARTIFACT_DIR=/tmp/artifacts \
    -e REPO_OWNER=kubevirt \
    -e REPO_NAME=kubevirt \
    -e JOB_NAME="$(echo "$(yq -r '.presets[].env[] | " -e "+.name+"="+.value' /home/dhiller/Projects/github.com/kubevirt.io/project-infra/github/ci/prow/files/jobs/kubevirt/kubevirt/kubevirt-presets.yaml | tr '\n' ' ')")" \
    --rm "${TEST_IMAGE}" '/tmp/scripts/test.sh' \
|| (
    #cat "$SCRIPT_DIR/test.sh"
    #ls -la "$SHARED_DIR"
    exit 1
)
