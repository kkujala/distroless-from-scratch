#!/usr/bin/env bash
set -Eeuo pipefail

image_a="${1}"
image_b="${2}"

tmp_dir="${TMPDIR:-/tmp}"

function get_image_path() {
    local image=
    image="${1}"

    local path=
    path="${tmp_dir}/${image//[^a-zA-Z0-9]/-}"

    local canonical_path=
    canonical_path="$(readlink --canonicalize "${path}")"

    if [[ "${canonical_path}" == / ]]; then
        echo >&2 "Image path cannot point to /"
        exit 1
    fi

    echo "${path}"
}

for image in "${image_a}" "${image_b}"; do
    echo "processing ${image}"
    image_path=$(get_image_path "${image}")

    if [[ -d "${image_path}" ]]; then
        chmod --recursive u+rw "${image_path}"
        rm --force --recursive "${image_path}"
    fi

    mkdir --parents "${image_path}"
    (
        cd "${image_path}"
        podman save --output=content.tar "${image}"
        tar --extract --file content.tar
        (
            mkdir --parents all
            cd all
            find .. \
                -mindepth 1 \
                -maxdepth 1 \
                \( \
                    -name "*.tar" \
                    -and -not -name "content.tar" \
                \) \
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
done

diff_path_a=$(get_image_path "${image_a}")
diff_path_b=$(get_image_path "${image_b}")

diff_path_a_all="${diff_path_a}"/all
diff_path_b_all="${diff_path_b}"/all

diff_path_a_last="${diff_path_a}"/last
diff_path_b_last="${diff_path_b}"/last

function get_inspect_command() {
    local image_name=
    image_name="${1}"

    echo "podman inspect '${image_name}'"
}

echo "Container image inspection"
echo

echo "vimdiff \\"
echo "    <(podman inspect ${image_a}) \\"
echo "    <(podman inspect ${image_b})"
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
