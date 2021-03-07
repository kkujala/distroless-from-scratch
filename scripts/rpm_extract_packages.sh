#!/usr/bin/env bash
set -Eeuo pipefail

echo "Running ${BASH_SOURCE[0]}"

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

mapfile -t packages < <(
    find /tmp \
        -type f \
        -name '*.rpm' \
    | sort
)

for package in "${packages[@]}"; do
    process "${package}"
done
