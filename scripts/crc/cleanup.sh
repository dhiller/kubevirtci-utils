#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

crc stop
crc delete -f
crc cleanup -f
#podman image prune -f
#docker image prune -f

