#!/bin/bash

set -euo pipefail

function usage {
    cat <<EOF
usage: $0 <search-term>

    Copies the flakefinder daily reports from the google cloud storage,
    greps them for the search term and creates a list of urls leading
    to the reports

    Example:
    > $0 test_id:1632

    Requirements:
    * gsutil installed
      https://cloud.google.com/storage/docs/gsutil_install

EOF
}

function check_gsutil_installed {
    if ! command -V gsutil > /dev/null; then
        usage
        echo 'gsutil is not installed'
        exit 1
    fi
}

function check_args {
    if [ $# -lt 1 ]; then
        usage
        exit 1
    fi  
}

function main {

    check_gsutil_installed
    check_args "$@"

    search_term="$1"

    cwd=$(pwd)
    temp_dir=$(mktemp -d)

    trap 'rm -rf $temp_dir; cd $cwd' SIGINT SIGTERM EXIT

    cd $temp_dir

    gsutil -m cp 'gs://kubevirt-prow/reports/flakefinder/kubevirt/kubevirt/flakefinder-*-024h.html' .

    grep -il "${search_term}" flakefinder-*.html | sort -r | sed 's#.*#https://storage.googleapis.com/kubevirt-prow/reports/flakefinder/kubevirt/kubevirt/&#'
}

main "$@"
