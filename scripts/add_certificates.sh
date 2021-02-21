#!/usr/bin/env bash
set -Eeuo pipefail

echo "Running ${BASH_SOURCE[0]}"

mkdir --parents /tmp/copy/etc/ssl/certs
cp \
    /etc/ssl/certs/ca-certificates.crt \
    /tmp/copy/etc/ssl/certs/
