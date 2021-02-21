#!/usr/bin/env bash
set -Eeuo pipefail

echo "${0}"

mkdir --parents /tmp/copy/etc
cp \
    /etc/nsswitch.conf \
    /tmp/copy/etc/
