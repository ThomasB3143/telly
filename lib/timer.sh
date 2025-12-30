#!/usr/bin/env bash

start_timer() {
    local launcher="$1"
    local timeout_ms="$2"
    local option="$3"
    local pid_file
    pid_file="$(timer_pid_file "$launcher")"

    (
        sleep "$(ms_to_seconds "$timeout_ms")"
        execute_option "$option"
        clear_timer "$(state_file_for "$launcher")" "$INDEX"
        close_menu_notification "$launcher"
        show_selected_notification "$launcher" "$INDEX"
        rm -f "$pid_file"
    ) &
    
    echo $! >"$pid_file"
}

stop_timer() {
    local launcher="$1"
    local pid_file

    pid_file="$(timer_pid_file "$launcher")"

    if [[ -f "$pid_file" ]]; then
        local pid
        pid="$(cat "$pid_file")"

        kill "$pid" 2>/dev/null || true
        rm -f "$pid_file"
    fi
}


timer_pid_file() {
    echo "$STATE_DIR/$1.timer.pid"
}

ms_to_seconds() {
    awk "BEGIN { printf \"%.3f\", $1 / 1000 }"
}