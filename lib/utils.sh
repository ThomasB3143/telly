#!/usr/bin/env bash

die() {
    # Prints error message and exits
    echo "teevee: $*" >&2
    exit 1
}

check_array_len() {
    local name="$1"
    declare -n arr="$name"

    [[ "${#arr[@]}" -eq "$num_options" ]] \
        || die "$name must have exactly $num_options elements (has ${#arr[@]})"
}

print_help() {
    cat <<EOF
teevee — single-button cyclic launcher

Usage:
  teevee run <launcher>
  teevee list
  teevee init
  teevee init <launcher>

Commands:
  run <launcher>     Run the given launcher
  list               List all launchers in ~/.config/teevee
  init               Create the teevee config directory (~/.config/teevee)
  init <launcher>    Create the config directory (if needed) and initialise
                     a launcher with an example launcher.conf and options/

Options:
  -h, --help                             Show this help message
  -v, --version                          Print version
  -V <launcher>, --valid <launcher>      Check whether launcher is valid
EOF
}
