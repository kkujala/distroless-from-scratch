#!/usr/bin/env bash
set -Eeuo pipefail

echo "Running ${BASH_SOURCE[0]}"

mkdir --parents /tmp/cache

yum --assumeyes makecache
yum --assumeyes install yum-utils

for package in "${@}"; do
    yumdownloader \
        --assumeyes \
        --downloaddir /tmp/cache \
        "${package}"
done
