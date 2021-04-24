#!/usr/bin/env bash
set -Eeuo pipefail

echo "Running ${BASH_SOURCE[0]}"

mkdir --parents /tmp/copy/var/lib/rpm

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

faketime @0 \
    rpm \
        --dbpath /tmp/copy/var/lib/rpm \
        --initdb
