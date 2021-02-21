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

mapfile -t file_names < <(
    find /tmp/copy
)

for file_name in "${file_names[@]}"; do
    process "${file_name}"
done
