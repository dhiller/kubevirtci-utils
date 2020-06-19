#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

set -xeuo pipefail

crc setup
# --enable-experimental-features
crc config set memory 24576
crc start 
# --log-level debug
