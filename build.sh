#!/usr/bin/env bash
set -Eeuo pipefail

# This script builds the distroless base images.

script="${BASH_SOURCE[0]}"
repo_dir="$(cd "$(dirname "${script}")" >/dev/null 2>&1 && pwd -P)"

oss=(
    alpine3
    debian12
    opensuseleap15
    rockylinux9
)
oss_list="${oss[*]}"
oss_list="${oss_list// /,}"

images=(
    builder
    static
    base
    cc
    java11
    java8
    nodejs
)
images_list="${images[*]}"
images_list="${images_list// /,}"

tags=(
    latest
    debug
    nonroot
    debug-nonroot
)
tags_list="${tags[*]}"
tags_list="${tags_list// /,}"

function usage() {
    echo -n "Usage: ${script} [OPTION]...
Build distroless images from sratch.

-b                use buildah for building,           this is the default
-d                use docker for building
-o os[,os]        list of operating systems to build, by default ${oss_list}
-i image[,image]  list of images to build,            by default ${images_list}
-t tag[,tag]      list of tags to build,              by default ${tags_list}
-h                prints this help
"
}

function validate_value() {
    local default=
    default="${1}"
    local value=
    value="${2}"
    local default_array=()

    IFS=',' read -ra default_array <<< "${default}"
    for default_value in "${default_array[@]}"; do
        if [[ "${default_value}" == "${value}" ]]; then
            return
        fi
    done

    return 1
}

function validate_input() {
    local default=
    default="${1}"
    local input=
    input="${2}"
    local input_array=()

    IFS=',' read -ra input_array <<< "${input}"
    for value in "${input_array[@]}"; do
        if ! validate_value "${default}" "${value}"; then
            echo >&2 "${value} was not found in ${default}"
            exit 1
        fi
    done
}

builder=buildah

while getopts bdo:i:t:h option; do
    case "${option}" in
        b)
           builder=buildah
           ;;
        d)
           builder=docker
           ;;
        o)
           validate_input "${oss_list}" "${OPTARG}"
           IFS=',' read -ra oss <<< "${OPTARG}"
           ;;
        i)
           validate_input "${images_list}" "${OPTARG}"
           IFS=',' read -ra images <<< "${OPTARG}"
           ;;
        t)
           validate_input "${tags_list}" "${OPTARG}"
           IFS=',' read -ra tags <<< "${OPTARG}"
           ;;
        h)
           usage
           exit
           ;;
        *)
           usage >&2
           exit 1
           ;;
    esac
done

echo "Running ${script}"

for os in "${oss[@]}"; do

    for image in "${images[@]}"; do
        image+="-${os}"

        for tag in "${tags[@]}"; do
            containerfile="${repo_dir}/containerfiles/${image}"

            if [[ "${tag}" != latest ]]; then
                containerfile="${containerfile}-${tag}"
            fi

            if [[ ! -e "${containerfile}" ]]; then
                continue
            fi

            if [[ "${image}" =~ java(8|11|17) ]]; then
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

            echo -e -n "\n\nBuilding ${containerfile} as image ${image_tag} with "
            echo -e "${builder}\n\n"

            case "${builder}" in
                buildah)
                    buildah build-using-dockerfile \
                        --file="${containerfile}" \
                        --force-rm=false \
                        --no-cache \
                        --rm=false \
                        --tag="${image_tag}" \
                        --timestamp=0 \
                        "${repo_dir}"
                    ;;
                docker)
                    docker build \
                        --file="${containerfile}" \
                        --tag="${image_tag}" \
                        "${repo_dir}"
                    ;;
                *)
                    ;;
            esac

            echo -e -n "\nBuilt ${containerfile} as image ${image_tag} with "
            echo -e "${builder}"
        done
    done
done
