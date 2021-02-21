#!/usr/bin/env bash
set -Eeuo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"

oss=(
    alpine3
    centos8
    debian10
    opensuseleap15
)

if [[ "${#}" -ne 0 ]]; then
    oss=("${@}")
fi

for os in "${oss[@]}"; do
    images=(
        static-"${os}"
        base-"${os}"
        cc-"${os}"
        java11-"${os}"
        java8-"${os}"
        nodejs-"${os}"
    )

    tags=(
        latest
        debug
        nonroot
        debug-nonroot
    )

    for image in "${images[@]}"; do
        for tag in "${tags[@]}"; do
            dockerfile="${repo_dir}/dockerfiles/Dockerfile-${image}"
            if [[ "${tag}" != latest ]]; then
                dockerfile="${dockerfile}-${tag}"
            fi

            if [[ "${image}" =~ java(8|11) ]]; then
                version="${BASH_REMATCH[1]}"
                image_name="${image/${version}/}"
                if [[ "${tag}" != latest ]]; then
                    tag="${version}-${tag}"
                else
                    tag="${version}"
                fi
            else
                image_name="${image}"
            fi

            image_tag="localhost/distroless-from-scratch/${image_name}:${tag}"

            echo -e "\n\nBuilding ${dockerfile} as image ${image_tag}\n\n"
            buildah bud \
                --file="${dockerfile}" \
                --layers=true \
                --tag="${image_tag}" \
                --timestamp=0 \
                "${repo_dir}"
        done
    done
done
