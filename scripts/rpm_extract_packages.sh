#!/usr/bin/env bash
set -Eeuo pipefail

echo "Running ${BASH_SOURCE[0]}"

mkdir --parents /tmp/copy

if ! command -v faketime &> /dev/null; then
    if command -v yum &> /dev/null; then
        yum --assumeyes install epel-release.noarch
        yum --assumeyes makecache
        yum --assumeyes install libfaketime.x86_64
    fi

    if command -v zypper &> /dev/null; then
        zypper refresh
        zypper install --no-confirm libfaketime
    fi
fi

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

    faketime @0 \
        rpm \
            --info \
            --package "${package}" \
            --query \
        | sed \
            --expression="s/(not installed)/$(date --date=@0)/" \
            --expression='$s/.*//' \
        >> /tmp/copy/packages.txt

    faketime @0 \
        rpm \
            --dbpath /tmp/copy/var/lib/rpm \
            --install "${package}" \
            --justdb \
            --nocaps \
            --nocontexts \
            --nodeps \
            --nofiledigest \
            --noorder \
            --noscripts \
            --notriggers

    faketime @0 \
        rpm \
            --dbpath /tmp/copy/var/lib/rpm \
            --rebuilddb
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
