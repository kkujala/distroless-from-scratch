#!/usr/bin/env bash
set -Eeuo pipefail

echo "Running ${BASH_SOURCE[0]}"

mkdir --parents /tmp/copy

function extract() {
    local package=
    package="${1}"

    tar \
        --directory=/tmp/copy \
        --exclude='.PKGINFO' \
        --exclude='.SIGN*' \
        --extract \
        --file="${package}"
}

function store_package_data() {
    local package=
    package="${1}"

    {
        tar \
            --extract \
            --file="${package}" \
            --to-stdout \
            .PKGINFO
        echo
    } >> /tmp/copy/packages.txt
}

function process() {
    local package=
    package="${1}"

    extract "${package}"
    store_package_data "${package}"
}

mapfile -t packages < <(
    find /tmp \
        -mindepth 1 \
        -maxdepth 1 \
        -type f \
        -name '*.apk'
)

for package in "${packages[@]}"; do
    process "${package}"
done
