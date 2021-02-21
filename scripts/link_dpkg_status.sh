#!/usr/bin/env bash
set -Eeuo pipefail

echo "${0}"

mkdir --parents /tmp/copy/var/lib/dpkg

ln -s \
    /packages.txt \
    /tmp/copy/var/lib/dpkg/status
