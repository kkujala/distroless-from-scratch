#!/usr/bin/env bash
set -Eeuo pipefail

echo "Running ${BASH_SOURCE[0]}"

for package in "${@}"; do
    yum install \
        --assumeyes \
        "${package}"
done
