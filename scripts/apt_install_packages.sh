#!/usr/bin/env bash
set -Eeuo pipefail

echo "${0}"

apt update

mkdir --parents /usr/share/man/man1
for package in "${@}"; do
    apt install --yes "${package}"
done
