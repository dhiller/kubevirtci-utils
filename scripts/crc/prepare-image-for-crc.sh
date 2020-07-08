#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

set -euo pipefail

podman build -t kubevirt-test-pr -f hack/ci/Dockerfile.ci-pr .
