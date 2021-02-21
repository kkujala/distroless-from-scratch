#!/usr/bin/env bash
set -Eeuo pipefail

echo "Running ${BASH_SOURCE[0]}"

busybox_binary=1.31.0-defconfig-multiarch-musl/busybox-x86_64
busybox_url=https://busybox.net/downloads/binaries/"${busybox_binary}"

mkdir --parents /tmp/copy/bin
curl \
    --fail \
    --location \
    --output /tmp/copy/bin/busybox \
    --show-error \
    --silent \
    "${busybox_url}"

chmod 755 /tmp/copy/bin/busybox
for busybox_command in $(
        /tmp/copy/bin/busybox --list \
        | grep --invert-match busybox
    ); do

    ln --symbolic \
        /bin/busybox \
        /tmp/copy/bin/"${busybox_command}"
done

/tmp/copy/bin/busybox \
| sed '/^$/,$d' \
>> /tmp/copy/packages.txt
