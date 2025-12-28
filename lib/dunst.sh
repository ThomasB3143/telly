#!/usr/bin/env bash

show_menu_notification() {
    local launcher="$1"
    local text="$2"

    local id
    id=$(dunstify \
        -p \
        -h "string:x-dunst-stack-tag:$launcher" \
        -h "int:transient:1" \
        "$text")

    echo "$id"
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
