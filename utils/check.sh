#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
repo_dir="$(cd "${script_dir}/.." >/dev/null 2>&1 && pwd -P)"

function process() {
    local dockerfile=
    dockerfile="${1#*/}"
    file_name=/tmp/"${dockerfile////-}".sh

    echo "Processing ${dockerfile} as ${file_name}"

    {
        echo '#!/usr/bin/env bash'
        echo 'set -euo pipefail'
    } > "${file_name}"

    sed --quiet '/RUN :/,/&& :/p' "${dockerfile}" \
    | sed 's,RUN ,,' \
    >> "${file_name}"

    check_file "${file_name}"
    echo
}

function check_file() {
    local file_name=
    file_name="${1}"

    echo "Checking ${file_name}"

    shellcheck "${file_name}"
}

export -f process
export -f check_file

(
    cd "${repo_dir}"

    find . \
        -type f \
        -name 'Dockerfile-*' \
        -exec bash -c 'process "${1}"' _ {} \;

    find . \
        -type f \
        -name '*.sh' \
        -exec bash -c 'check_file "${1}"' _ {} \;
)
