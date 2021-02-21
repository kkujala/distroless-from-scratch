#!/usr/bin/env bash
set -Eeuo pipefail

echo "Running ${BASH_SOURCE[0]}"

mkdir --parents /tmp/copy/var/lib/dpkg

ln -s \
    /packages.txt \
    /tmp/copy/var/lib/dpkg/status
