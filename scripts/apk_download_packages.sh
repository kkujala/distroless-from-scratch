#!/usr/bin/env bash
set -euo pipefail

echo "${0}"

apk update

for package in "${@}"; do
    apk fetch --output /tmp "${package}"
done
