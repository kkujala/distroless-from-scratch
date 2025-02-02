#!/usr/bin/env bash
set -Eeuo pipefail

echo "Running ${BASH_SOURCE[0]}"

mkdir --parents /tmp/copy

if ! command -v cpio &> /dev/null; then
    if command -v yum &> /dev/null; then
        yum --assumeyes install cpio.x86_64
    fi
fi

if ! command -v faketime &> /dev/null; then
    if command -v yum &> /dev/null; then
        yum --assumeyes install epel-release.noarch
        yum --assumeyes makecache
        yum --assumeyes install libfaketime.x86_64
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

    # This is done to avoid "error: failed to replace old database with new
    # database! rpm rebuilddb", which strace reveals to be "Invalid
    # cross-device link" error.
    cp --recursive /tmp/copy/var/lib/rpm /tmp/copy/var/lib/rpm_new
    rm --force /tmp/copy/var/lib/rpm_new/.rpm.lock

    faketime @0 \
        rpm \
            --dbpath /tmp/copy/var/lib/rpm_new \
            --rebuilddb

    rm --force --recursive /tmp/copy/var/lib/rpm
    mv /tmp/copy/var/lib/rpm_new /tmp/copy/var/lib/rpm
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
