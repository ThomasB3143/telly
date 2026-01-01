#!/usr/bin/env bash

find_launcher() {
    # Checks if a launcher directory exists
    local name="$1"
    local user_path="$TEEVEE_USER_CONFIG/$name"
    local system_path="$TEEVEE_ROOT/$name"

    if [[ -d "$user_path" ]]; then
        validate_launcher "$user_path"
        echo "$user_path"
        return
    fi

    if [[ -d "$system_path" ]]; then
        validate_launcher "$system_path"
        echo "$system_path"
        return
    fi

    die "launcher '$name' not found"
}

validate_launcher() {
    # Checks if a launcher directory is valid
    local dir="$1"

    [[ -f "$dir/launcher.conf" ]] \
        || die "launcher missing launcher.conf: $dir"

    [[ -d "$dir/options" ]] \
        || die "launcher missing options directory: $dir"

    shopt -s nullglob
    local opts=("$dir/options/"*.sh)
    shopt -u nullglob

    (( ${#opts[@]} > 0 )) \
        || die "launcher has no option scripts: $dir"

    # Check if the launcher.conf is valid
    validate_config "$dir"
}

list_launchers() {
    local user_path="$TEEVEE_USER_CONFIG/"

    # Check the user path
    if [[ -d "$user_path" ]]; then
        shopt -s nullglob
        local user_launchers=("$user_path/"*/)
        shopt -u nullglob
        local user_list="Found ${#user_launchers[@]} launchers in ${user_path}"$'\n'
        for launcher in "${user_launchers[@]}"; do
            launcher="${launcher%/}"
            launcher="${launcher##*/}"
            user_list+=" - $launcher"$'\n'
        done
        user_list="${user_list%$'\n'}"
        echo "$user_list"
    else
        die "No $user_path found, try running \"teevee init\""
    fi
}

create_launcher() {
    local name="$1"
    local dir="$TEEVEE_USER_CONFIG/$name"
    local conf="$dir/launcher.conf"
    local opts="$dir/options"

    # Check if .config/teevee/ exists
    [[ -d "$TEEVEE_USER_CONFIG" ]] || (mkdir -p "$TEEVEE_USER_CONFIG" && echo "Initialised config directory at $TEEVEE_USER_CONFIG")

    # Refuse to overwrite a complete launcher
    if [[ -d "$dir" && -f "$conf" && -d "$opts" ]]; then
        die "Launcher $name already exists at $dir"
    fi

    # Create directory structure
    mkdir -p "$opts"

    # Create launcher.conf only if it doesn't already exist
    if [[ ! -f "$conf" ]]; then
        cat >"$conf" <<'EOF'
# The time in ms until the current option is selected
# DEFAULT: TIMEOUT_MS=1000
TIMEOUT_MS=2000

# The title shown in the dunst popup
# DEFAULT: Name of the launcher directory
TITLE="Options:"

# The order in which options appear in the launcher
# DEFAULT: Alphabetically ordered
OPTION_ORDER=(
    "opt1.sh"
    "opt2.sh"
    "opt3.sh"
)

# The name of each option, in the same order as the option scripts in OPTION ORDER
# DEFAULT: Option names are set to their filepath
OPTIONS=(
    "Option 1"
    "Option 2"
    "Option 3"
)

# The line displayed for each option when hovered over
# Same order as OPTIONS
# DEFAULT: " * <OPTION>"
HOVER_OPTIONS=(
    "This is option 1"
    "Hovering over option 2!"
    " * Option 3"
    "Option 4"
)

# The text content of the notification raised on selection of each option
# Same order as OPTIONS
# DEFAULT: Identical to OPTIONS
SELECTED_TEXT=(
    "We picked option 1"
    "activating option 2"
    "opt 3 selected"
)

# The icon filepath used in the dunst popup
# DEFAULT: The default dunst icon
GLOBAL_ICON="/path/to/allopts.jpg"

# The icon filepath used when hovering over each option
# Same order as OPTIONS
# DEFAULT: All set to GLOBAL_ICON
ICONS=(
    "/path/to/opt1img.jpg"
    "/path/to/opt2img.jpg"
    "/path/to/opt3img.jpg"
)

# The icon filepath used alongside SELECTED_TEXT
# Same order as OPTIONS
# DEFAULT: All set to ICONS
SELECTED_ICONS=(
    "/path/to/opt1selectedimg.jpg"
    "/path/to/opt2selectedimg.jpg"
    "/path/to/opt3selectedimg.jpg"
)
EOF
    fi

    echo "Launcher $name initialised at $dir"
}
