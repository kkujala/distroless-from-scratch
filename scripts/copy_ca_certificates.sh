#!/usr/bin/env bash
set -Eeuo pipefail

echo "Running ${BASH_SOURCE[0]}"

mapfile -t cert_files < <(
    find etc/pki \
        -name "cacerts*" \
        -o -name "*.0" \
        -o -name "*.crt" \
        -o -name "*.pem"
)

for cert_file in "${cert_files[@]}"; do
    tar --create --dereference "${cert_file}" \
    | tar --extract --directory=/tmp/copy
done
