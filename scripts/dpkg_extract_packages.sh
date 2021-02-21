#!/usr/bin/env bash
set -Eeuo pipefail

echo "Running ${BASH_SOURCE[0]}"

mkdir --parents /tmp/copy

function extract() {
    local package=
    package="${1}"

    dpkg-deb --extract "${package}" /tmp/copy
}

function store_package_data() {
    local package=
    package="${1}"

    dpkg-deb --info "${package}" \
    | sed \
        --quiet \
        --expression='s,^ ,,' \
        --expression='/^Package:/,$p' \
        --expression='s/^Package:.*/Status: install ok installed/p' \
        --expression='$s/.*//p' \
    >> /tmp/copy/packages.txt
}

function process() {
    local package=
    package="${1}"

    extract "${package}"
    store_package_data "${package}"
}

export -f extract
export -f store_package_data
export -f process

find /tmp/cache \
    -mindepth 1 \
    -maxdepth 1 \
    -type f \
    -name '*.deb' \
    -exec bash -c 'process "${1}"' _ {} \;
