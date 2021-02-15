#!/usr/bin/env bash
set -euo pipefail

echo "${0}"

mkdir --parents /tmp/copy/etc
grep '^\(nobody\|nogroup\|root\|staff\|tty\)' /etc/group > /tmp/copy/etc/group
grep '^\(nobody\|root\)' /etc/passwd > /tmp/copy/etc/passwd
