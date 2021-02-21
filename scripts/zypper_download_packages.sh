#!/usr/bin/env bash
set -Eeuo pipefail

echo "Running ${BASH_SOURCE[0]}"

zypper refresh

mkdir --parents /tmp/cache

for package in "${@}"; do
    zypper \
        --pkg-cache-dir /tmp/cache \
        download \
        "${package}"
done
