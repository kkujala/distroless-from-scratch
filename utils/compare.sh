#!/usr/bin/env bash
set -Eeuo pipefail

script="${BASH_SOURCE[0]}"

function usage() {
    echo -n "Usage: ${script} OPTION_A OPTION_B
Compare images.

-p image  use image from podman for checking
-d image  use image from docker for checking
-h        prints this help
"
}

if [[ "${#}" -ne 4 ]] && [[ "${#}" -ne 1 ]]; then
    usage >&2
    exit 1
fi

while getopts p:d:h option; do
    case "${option}" in
        p)
           if [[ "${OPTIND}" == 3 ]]; then
               image_a_tool=podman
               image_a="${OPTARG}"
           elif [[ "${OPTIND}" == 5 ]]; then
               image_b_tool=podman
               image_b="${OPTARG}"
           fi
           ;;
        d)
           if [[ "${OPTIND}" == 3 ]]; then
               image_a_tool=docker
               image_a="${OPTARG}"
           elif [[ "${OPTIND}" == 5 ]]; then
               image_b_tool=docker
               image_b="${OPTARG}"
           fi
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

function get_image_path() {
    local tool=
    tool="${1}"
    local image=
    image="${2}"

    local path=
    path="${tmp_dir}/${tool}-${image//[^a-zA-Z0-9]/-}"

    local canonical_path=
    canonical_path="$(readlink --canonicalize "${path}")"

    if [[ "${canonical_path}" == / ]]; then
        echo >&2 "Image path cannot point to /"
        exit 1
    fi

    echo "${path}"
}

function process() {
    local tool=
    tool="${1}"
    local image=
    image="${2}"

    echo "processing ${image} with ${tool}"
    image_path=$(get_image_path "${tool}" "${image}")

    if [[ -d "${image_path}" ]]; then
        chmod --recursive u+rw "${image_path}"
        rm --force --recursive "${image_path}"
    fi

    mkdir --parents "${image_path}"
    (
        cd "${image_path}"
        "${tool}" save --output=content.tar "${image}"
        tar --extract --file content.tar
        (
            mkdir --parents all
            cd all
            find .. \
                -mindepth 2 \
                -maxdepth 2 \
                -name "layer.tar" \
                -exec tar --extract --file {} \;
            touch --date=@0 .
        )
        (
            mkdir --parents last
            cd last
            last_layer="../$(sed 's/.*"\([^"]\+\)".*/\1/' ../manifest.json)"
            tar --extract --file "${last_layer}"
            touch --date=@0 .
        )
    )
}

echo "Running ${script}"

tmp_dir="${TMPDIR:-/tmp}"

process "${image_a_tool}" "${image_a}"
process "${image_b_tool}" "${image_b}"

diff_path_a=$(get_image_path "${image_a_tool}" "${image_a}")
diff_path_b=$(get_image_path "${image_b_tool}" "${image_b}")

diff_path_a_all="${diff_path_a}"/all
diff_path_b_all="${diff_path_b}"/all

diff_path_a_last="${diff_path_a}"/last
diff_path_b_last="${diff_path_b}"/last

function get_inspect_command() {
    local tool=
    tool="${1}"
    local image=
    image="${2}"

    echo "${tool} inspect '${image}'"
}

echo "Container image inspection"
echo

echo "vimdiff \\"
echo "    <($(get_inspect_command "${image_a_tool}" "${image_a}")) \\"
echo "    <($(get_inspect_command "${image_b_tool}" "${image_b}"))"
echo

echo "Complete filesystem from all layers"
echo

echo "vimdiff \\"
echo "    <(cd ${diff_path_a_all} && find | sort) \\"
echo "    <(cd ${diff_path_b_all} && find | sort)"
echo

echo "vimdiff \\"
echo "    <(cd ${diff_path_a_all} && find -type f | sort) \\"
echo "    <(cd ${diff_path_b_all} && find -type f | sort)"
echo

echo "vimdiff \\"
echo -n "    <(cd ${diff_path_a_all} && find -type f -exec md5sum {} \;"
echo " | sort --unique --key=2) \\"
echo -n "    <(cd ${diff_path_b_all} && find -type f -exec md5sum {} \;"
echo " | sort --unique --key=2)"
echo

echo "Filesystem from the last layer"
echo

echo "vimdiff \\"
echo "    <(cd ${diff_path_a_last} && find | sort) \\"
echo "    <(cd ${diff_path_b_last} && find | sort)"
echo

echo "vimdiff \\"
echo "    <(cd ${diff_path_a_last} && find -type f | sort) \\"
echo "    <(cd ${diff_path_b_last} && find -type f | sort)"
echo

echo "vimdiff \\"
echo -n "    <(cd ${diff_path_a_last} && find -type f -exec md5sum {} \;"
echo " | sort --unique --key=2) \\"
echo -n "    <(cd ${diff_path_b_last} && find -type f -exec md5sum {} \;"
echo " | sort --unique --key=2)"
echo
