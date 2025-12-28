#!/usr/bin/env bash

get_options() {
    # Returns all option scripts for a launcher
    local launcher_dir="$1"
    local options_dir="$launcher_dir/options"

    shopt -s nullglob
    local opts=("$options_dir/"*.sh)
    shopt -u nullglob

    # Sort explicitly (important!)
    IFS=$'\n' opts=($(sort <<<"${opts[*]}"))
    unset IFS

    echo "${opts[@]}"
}

execute_option() {
    local option="$1"

    if [[ ! -x "$option" ]]; then
        echo "telly: option not executable $option" >&2
        return 1
    fi

    "$option" &
}