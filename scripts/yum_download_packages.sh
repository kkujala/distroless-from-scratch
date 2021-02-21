#!/usr/bin/env bash
set -Eeuo pipefail

echo "${0}"

mkdir --parents /tmp/cache

yum --assumeyes makecache
yum --assumeyes install yum-utils

for package in "${@}"; do
    yumdownloader \
        --assumeyes \
        --downloaddir /tmp/cache \
        "${package}"
done
