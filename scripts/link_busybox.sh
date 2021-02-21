#!/usr/bin/env bash
set -Eeuo pipefail

echo "Running ${BASH_SOURCE[0]}"

busybox=/tmp/copy/bin/busybox

mkdir --parents /tmp/copy/bin

if [[ -e /tmp/copy/bin/busybox.static ]]; then
    busybox=/tmp/copy/bin/busybox.static
    ln -s \
        /bin/busybox.static \
        /tmp/copy/bin/busybox
fi

if [[ -e /tmp/copy/usr/bin/busybox-static ]]; then
    busybox=/tmp/copy/usr/bin/busybox-static
    ln -s \
        /usr/bin/busybox-static \
        /tmp/copy/bin/busybox
fi

for busybox_command in $(
        "${busybox}" --list \
        | grep -v busybox
    ); do

    ln -s \
        /bin/busybox \
        /tmp/copy/bin/"${busybox_command}"
done
