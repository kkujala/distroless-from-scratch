#!/usr/bin/env bash
set -euo pipefail

echo "${0}"

mkdir --parents /tmp/copy/etc/ssl/certs
cp \
    /etc/ssl/certs/ca-certificates.crt \
    /tmp/copy/etc/ssl/certs/
