#!/usr/bin/env ash
# shellcheck shell=dash
set -euo pipefail

echo Running "${0}"

apk update

for package in "${@}"; do
    apk add "${package}"
done
