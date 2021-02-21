#!/usr/bin/env bash
set -Eeuo pipefail

echo "${0}"

mkdir --parents /tmp/copy/usr/bin

function find_java_directory() {
    local path=/usr/lib/jvm

    if [[ -d /tmp/copy/usr/lib64/jvm ]]; then
        path=/usr/lib64/jvm
    fi

    cd /tmp/copy/"${path}"

    local directory=
    directory=$(
        find . \
            -type d \
            -name 'bin' \
        | sed 's,^[.]/,,' \
        | head -n 1
    )

    echo "${path}/${directory}"
}

java_directory="$(find_java_directory)"

mkdir --parents /tmp/copy/usr/bin
ln -s \
    "${java_directory}"/java \
    /tmp/copy/usr/bin/
