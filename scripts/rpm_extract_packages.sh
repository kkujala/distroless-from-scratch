#!/usr/bin/env bash
set -euo pipefail

echo "${0}"

mkdir --parents /tmp/copy

function extract() {
    local package=
    package="${1}"

    rpm2cpio "${package}" \
    | cpio \
        --directory=/tmp/copy \
        --extract \
        --make-directories
}

function store_package_data() {
    local package=
    package="${1}"

    rpm \
        --info \
        --package "${package}" \
        --query \
    | sed \
        --expression="s/(not installed)/$(date --date=@0)/" \
        --expression='$s/.*//' \
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

find /tmp \
    -type f \
    -name '*.rpm' \
    -exec bash -c 'process "${1}"' _ {} \;
