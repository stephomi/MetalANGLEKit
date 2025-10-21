#!/bin/bash

set -e

apply_git_patch() {
    local patch_file=$1

    if git apply --check --reverse <"$patch_file" >/dev/null 2>&1; then
        echo "Already applied $patch_file"
    else
        if git apply <"$patch_file" >/dev/null 2>&1; then
            echo "Applied $patch_file"
        else
            echo "Failed to apply $patch_file" >&2
            exit 1
        fi
    fi
}

cd "$(dirname "$0")"

export PATH="$(pwd)/depot_tools:$PATH"

cd angle

python3 scripts/bootstrap.py
gclient sync -D --force

apply_git_patch ../diff.patch
