#!/usr/bin/env bash
set -euo pipefail

echo "${0}"

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