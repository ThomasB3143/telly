load_launcher_config() {
    local launcher_dir="$1"
    local config_file="$launcher_dir/config"

    # Default values
    TIMEOUT_MS=1000

    if [[ -f "$config_file" ]]; then
        source "$config_file"
    fi
}