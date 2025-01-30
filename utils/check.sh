#!/usr/bin/env bash
set -Eeuo pipefail

# This script checks the shell script content in the containerfiles and all the
# shell script files.

echo "Running ${BASH_SOURCE[0]}"

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
repo_dir="$(cd "${script_dir}/.." >/dev/null 2>&1 && pwd -P)"

function extract_content() {
    local containerfile=
    containerfile="${1}"

    echo '#!/usr/bin/env bash'
    echo 'set -Eeuo pipefail'

    sed --quiet \
        --expression='/^RUN .*[\]$/,/[^\]$/p' \
        --expression='/^RUN .*[^\]$/p' \
        "${containerfile}" \
    | sed 's,^RUN ,,'
}

function process() {
    local containerfile=
    containerfile="${1}"

    echo "Checking ${containerfile} shell content"
    check_file <(extract_content "${containerfile}")
}

function check_file() {
    local file_name=
    file_name="${1}"

    shellcheck "${file_name}"
}

(
    cd "${repo_dir}"

    mapfile -t containerfiles < <(
        find containerfiles \
            -type f \
        | sort
    )

    for containerfile in "${containerfiles[@]}"; do
        process "${containerfile}"
    done

    mapfile -t script_files < <(
        find . \
            -name '*.sh' \
            -type f \
        | sort
    )

    for script_file in "${script_files[@]}"; do
        echo "Checking ${script_file}"
        check_file "${script_file}"
    done
)
