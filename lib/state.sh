#!/usr/bin/env bash

state_file_for() {
    local launcher="$1"
    echo "$STATE_DIR/$launcher.state"
}

load_state() {
    local file="$1"

    if [[ -f "$file" ]]; then
        source "$file"
    else
        INDEX=0
        LAST_TS=0
    fi
}

save_state() {
    local file="$1"
    local index="$2"
    local ts="$3"

    printf "INDEX=%s\nLAST_TS=%s\n" "$index" "$ts" >"$file"
}

clear_timer() {
    # Clears only the timer information, keeps INDEX
    local file="$1"
    local index="$2"

    printf "INDEX=%s\nLAST_TS=0\n" "$index" >"$file"
}

next_index() {
    local current="$1"
    local count="$2"

    if (( current + 1 < count )); then
        echo $((current + 1))
    else
        echo 0
    fi
}
