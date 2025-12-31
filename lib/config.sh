#!/usr/bin/env bash

load_launcher_config() {
    local launcher_dir="$1"
    local config_file="$launcher_dir/launcher.conf"

    # Default values
    TIMEOUT_MS=1000

    # Get options from options/
    shopt -s nullglob
    OPTION_ORDER=("$launcher_dir/options/"*)
    shopt -u nullglob
    IFS=$'\n' OPTION_ORDER=($(sort <<<"${OPTION_ORDER[*]}"))
    # Remove leading path
    OPTION_ORDER=("${OPTION_ORDER[@]##*/}")
    unset IFS

    OPTIONS=$OPTION_ORDER
    HOVER_OPTIONS=("${OPTIONS[@]/#/ * }")
    TITLE="${launcher_dir}"
    SELECTED_TEXT=$OPTIONS


    # Source launcher.conf if exists
    if [[ -f "$config_file" ]]; then
        source "$config_file"
    fi
}

create_config() {
    local config_dir="$TEEVEE_USER_CONFIG"

    mkdir -p "$config_dir"

    echo "Initialised config directory at $config_dir"
}

validate_config() (
    # Separate subshell for validation
    set -euo pipefail

    local launcher_dir="$1"
    local options_dir="${launcher_dir}/options"

    source "${launcher_dir}/launcher.conf"

    # Define function for error_flagging
    local error_found=0
    flag() {
        echo "teevee: $*" >&2
        error_found=1
    }

    # Check options/ exists
    [[ -d "${options_dir}" ]] \
        || flag "No options directory found at ${options_dir}"

    # Check TIMEOUT_MS
    # Must be a positive integer
    if [[ -v TIMEOUT_MS ]]; then
        [[ "$TIMEOUT_MS" =~ ^[0-9]+$ ]] \
            || flag "TIMEOUT_MS must be a positive integer"
    fi

    local num_options

    # Number of options is the length of OPTION_ORDER
    # If undefined, default to the number of files in options/ 
    if [[ -v OPTION_ORDER ]]; then
        num_options="${#OPTION_ORDER[@]}"

        # Check if all the files in OPTION_ORDER are executable and exist
        for option in "${OPTION_ORDER[@]}"; do
            [[ -x "${options_dir}/${option}" && -f "${options_dir}/${option}" ]] \
                || flag "Option ${options_dir}/${option}" not executable
        done

    else
        shopt -s nullglob
        local option_files=("${options_dir}"/*)
        shopt -u nullglob

        # Check if all the files in option_files are executable
        for option in "${option_files[@]}"; do
            [[ -x "$option" ]] \
                || flag "Option ${option}" not executable
        done
        (( ${#option_files[@]} > 0 )) \
            || flag "No option files found in ${options_dir}"

        num_options="${#option_files[@]}"
    fi

    (( num_options > 0 )) \
        || flag "Number of options must be greater than zero"

    check_array_len() {
        local name="$1"
        declare -n arr="$name"

        [[ "${#arr[@]}" -eq "$num_options" ]] \
            || flag "$name must have exactly $num_options elements (has ${#arr[@]})"
    }

    # Check length of each array to match num_options
    for var in \
        OPTION_ORDER \
        OPTIONS \
        HOVER_OPTIONS \
        SELECTED_TEXT \
        ICONS \
        SELECTED_ICONS
    do
        [[ -v $var ]] && check_array_len "$var"
    done

    # Image path checks
    if [[ -v GLOBAL_ICON ]]; then
        [[ -f "$GLOBAL_ICON" ]] \
            || flag "GLOBAL_ICON does not exist: $GLOBAL_ICON"
    fi

    if [[ -v ICONS ]]; then
        for icon in "${ICONS[@]}"; do
            [[ -f "$icon" ]] || flag "ICON does not exist: $icon"
        done
    fi

    if [[ -v SELECTED_ICONS ]]; then
        for icon in "${SELECTED_ICONS[@]}"; do
            [[ -f "$icon" ]] || flag "SELECTED_ICON does not exist: $icon"
        done
    fi

    if (( error_found )); then
        exit 1
    fi
)
