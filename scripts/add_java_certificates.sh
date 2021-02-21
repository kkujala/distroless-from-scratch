#!/usr/bin/env bash
set -Eeuo pipefail

echo "${0}"

mkdir --parents /tmp/copy/etc/ssl/certs/java
cp \
    /etc/ssl/certs/java/cacerts \
    /tmp/copy/etc/ssl/certs/java/
