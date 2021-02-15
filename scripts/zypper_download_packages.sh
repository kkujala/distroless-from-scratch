#!/usr/bin/env bash
set -euo pipefail

echo "${0}"

zypper refresh

mkdir --parents /tmp/cache

for package in "${@}"; do
    zypper \
        --pkg-cache-dir /tmp/cache \
        download \
        "${package}"
done
