#!/usr/bin/env bash

show_menu_notification() {
    local launcher="$1"
    local text="$2"
    local index="${3:-}"
    local id_file
    local id

    id_file="$(notification_id_file "$launcher")"

    # Build icon argument
    local icon_args=()
    if [[ -n "$index" && -v ICONS[$index] ]]; then
        icon_args=(-i "${ICONS[$index]}")
    elif [[ -v GLOBAL_ICON ]]; then
        icon_args=(-i "$GLOBAL_ICON")
    fi

    if [[ -f "$id_file" ]]; then
        # Replace existing notification by ID (icon WILL update)
        id=$(dunstify \
            -p \
            -r "$(cat "$id_file")" \
            "${icon_args[@]}" \
            -h "string:x-dunst-stack-tag:$launcher" \
            -h "int:transient:1" \
            "$text")
    else
        # Create new notification
        id=$(dunstify \
            -p \
            "${icon_args[@]}" \
            -h "string:x-dunst-stack-tag:$launcher" \
            -h "int:transient:1" \
            "$text")
    fi

    echo "$id"
}


show_selected_notification() {
    local launcher="$1"
    local index="$2"
    local id
    # Check for per-option selected icon, then per-option icon, then global icon, then default
    if [[ -v SELECTED_ICONS ]]; then
        id=$(dunstify \
        -p \
        -i "${SELECTED_ICONS[$index]}" \
        -h "string:x-dunst-stack-tag:$launcher" \
        -h "int:transient:1" \
        "${SELECTED_TEXT[$index]}")

    elif [[ -v ICONS ]]; then
        id=$(dunstify \
        -p \
        -i "${ICONS[$index]}" \
        -h "string:x-dunst-stack-tag:$launcher" \
        -h "int:transient:1" \
        "${SELECTED_TEXT[$index]}")

    elif [[ -v GLOBAL_ICON ]]; then
        id=$(dunstify \
        -p \
        -i "$GLOBAL_ICON" \
        -h "string:x-dunst-stack-tag:$launcher" \
        -h "int:transient:1" \
        "${SELECTED_TEXT[$index]}")

    else
        id=$(dunstify \
        -p \
        -h "string:x-dunst-stack-tag:$launcher" \
        -h "int:transient:1" \
        "${SELECTED_TEXT[$index]}")
    fi
}

close_menu_notification() {
    local launcher="$1"
    local id_file

    id_file="$(notification_id_file "$launcher")"

    if [[ -f "$id_file" ]]; then
        local nid
        nid="$(cat "$id_file")"

        dunstify -C "$nid" 2>/dev/null || true
        rm -f "$id_file"
    fi
}

notification_id_file() {
    echo "$STATE_DIR/$1.notify.id"
}
