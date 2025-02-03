#!/usr/bin/env bash
set -Eeuo pipefail

echo "Running ${BASH_SOURCE[0]}"

mkdir --parents /tmp/copy/var/lib/rpm

faketime @0 \
    rpm \
        --dbpath /tmp/copy/var/lib/rpm \
        --initdb
