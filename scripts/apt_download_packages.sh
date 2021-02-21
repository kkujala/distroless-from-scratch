#!/usr/bin/env bash
set -Eeuo pipefail

echo "${0}"

apt update

(
    mkdir --parents /tmp/cache
    chmod 777 /tmp/cache
    cd /tmp/cache
    for package in "${@}"; do
        apt download "${package}"
    done
)
