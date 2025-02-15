#!/usr/bin/env bash
set -Eeuo pipefail

echo "Running ${BASH_SOURCE[0]}"

for package in "${@}"; do
    apk fetch --output /tmp "${package}"
done
