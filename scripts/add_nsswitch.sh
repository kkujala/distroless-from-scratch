#!/usr/bin/env bash
set -euo pipefail

echo "${0}"

mkdir --parents /tmp/copy/etc
cp \
    /etc/nsswitch.conf \
    /tmp/copy/etc/
