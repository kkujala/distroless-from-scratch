#!/usr/bin/env bash
set -Eeuo pipefail

echo "Running ${BASH_SOURCE[0]}"

mkdir --parents /tmp/cache

for package in "${@}"; do
    yumdownloader \
        --assumeyes \
        --downloaddir /tmp/cache \
        "${package}"
done
