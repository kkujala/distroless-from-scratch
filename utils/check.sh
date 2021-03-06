#!/usr/bin/env bash
set -Eeuo pipefail

# This script checks the shell script content in the dockerfiles and all the
# shell script files.

echo "Running ${BASH_SOURCE[0]}"

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
repo_dir="$(cd "${script_dir}/.." >/dev/null 2>&1 && pwd -P)"

function process() {
    local dockerfile=
    dockerfile="${1#*/}"
    local file_name=
    file_name=/tmp/"${dockerfile////-}".sh

    echo "Processing ${dockerfile} as ${file_name}"

    {
        echo '#!/usr/bin/env bash'
        echo 'set -Eeuo pipefail'
    } > "${file_name}"

    sed --quiet \
        --expression='/^RUN .*[\]$/,/[^\]$/p' \
        --expression='/^RUN .*[^\]$/p' \
        "${dockerfile}" \
    | sed 's,^RUN ,,' \
    >> "${file_name}"

    check_file "${file_name}"
    rm "${file_name}"
    echo
}

function check_file() {
    local file_name=
    file_name="${1}"

    echo "Checking ${file_name}"

    shellcheck "${file_name}"
}

(
    cd "${repo_dir}"

    mapfile -t dockerfiles < <(
        find . \
            -type f \
            -name 'Dockerfile-*'
    )

    for dockerfile in "${dockerfiles[@]}"; do
        process "${dockerfile}"
    done

    mapfile -t scriptfiles < <(
        find . \
            -type f \
            -name '*.sh'
    )

    for scriptfile in "${scriptfiles[@]}"; do
        check_file "${scriptfile}"
    done
)
