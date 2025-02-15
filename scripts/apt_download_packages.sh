#!/usr/bin/env bash
set -Eeuo pipefail

echo "Running ${BASH_SOURCE[0]}"

(
    mkdir --parents /tmp/cache
    chmod 777 /tmp/cache
    cd /tmp/cache
    for package in "${@}"; do
        apt download "${package}"
    done
)
