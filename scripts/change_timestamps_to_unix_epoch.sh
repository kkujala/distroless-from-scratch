#!/usr/bin/env bash
set -Eeuo pipefail

echo "Running ${BASH_SOURCE[0]}"

function process() {
    local file_name=
    file_name="${1}"

    touch \
        --date='@0' \
        --no-dereference \
        "${file_name}"
}

export -f process

find /tmp/copy \
    -exec bash -c 'process "${1}"' _ {} \;
