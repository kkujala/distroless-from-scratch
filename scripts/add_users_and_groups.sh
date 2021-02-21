#!/usr/bin/env bash
set -Eeuo pipefail

echo "Running ${BASH_SOURCE[0]}"

mkdir --parents /tmp/copy/etc
grep '^\(nobody\|nogroup\|root\|staff\|tty\)' /etc/group > /tmp/copy/etc/group
grep '^\(nobody\|root\)' /etc/passwd > /tmp/copy/etc/passwd
