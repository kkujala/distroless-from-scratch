#!/usr/bin/env bash
set -Eeuo pipefail

echo "${0}"

mkdir --parents /tmp/copy/home
mkdir --mode=0700 /tmp/copy/home/nonroot
chown 65532:65532 /tmp/copy/home/nonroot

echo 'nonroot:x:65532:' >> /tmp/copy/etc/group

echo 'nonroot:x:65532:65532:nonroot:/home/nonroot:/usr/sbin/nologin' \
>> /tmp/copy/etc/passwd
