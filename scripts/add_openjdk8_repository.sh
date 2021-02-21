#!/usr/bin/env bash
set -Eeuo pipefail

echo "Running ${BASH_SOURCE[0]}"

curl \
    --fail \
    --location \
    --show-error \
    --silent \
    https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public \
| apt-key add -

add-apt-repository \
    --yes \
    https://adoptopenjdk.jfrog.io/adoptopenjdk/deb
