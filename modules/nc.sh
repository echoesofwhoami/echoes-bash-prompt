#!/bin/bash

NC_DIR="$HOME/.nc_listeners"
NC_BIN="${NC_BIN:-$(command -v ncat || command -v nc || command -v netcat)}"
mkdir -p "$NC_DIR"

_nc_info() { echo "$NC_DIR/${1}.info"; }
_nc_log()  { echo "$NC_DIR/${1}.log"; }
_nc_rm()   { rm -f "$(_nc_info "$1")" "$(_nc_log "$1")"; }

_nc_find() {
    for f in "$NC_DIR"/*.info; do
        [[ -f "$f" ]] || continue
        source "$f"
        [[ "$1" == "$name" || "$1" == "$pid" || "$1" == "$port" ]] && { echo "$name"; return 0; }
    done
    return 1
}

ncstart() {
    local port="$1" proto="${2:-tcp}" name="${3:-nc_${1}_$(date +%s)}"
    [[ -z "$port" ]] && { echo "Usage: ncstart <port> [proto] [name]"; return 1; }
    [[ -z "$NC_BIN" ]] && { echo "Error: no netcat binary found"; return 1; }
    
    local log_file="$NC_DIR/${name}.log"
    local info_file="$NC_DIR/${name}.info"
    
    "$NC_BIN" -z localhost "$port" 2>/dev/null && { echo "Port $port in use"; return 1; }

    if [[ "$proto" == "udp" ]]; then
        ( "$NC_BIN" -ulknp "$port" > "$log_file" 2>&1 & echo $! > "$info_file.pid" )
    else
        ( "$NC_BIN" -lknp "$port" > "$log_file" 2>&1 & echo $! > "$info_file.pid" )
    fi
    
    sleep 0.2
    local pid=$(cat "$info_file.pid" 2>/dev/null)
    rm -f "$info_file.pid"
    
    if ! kill -0 "$pid" 2>/dev/null; then
        echo "Error: listener failed to start"
        return 1
    fi

    printf 'pid=%s\nport=%s\nprotocol=%s\nname=%s\nstarted="%s"\nlog_file=%s\n' \
        "$pid" "$port" "$proto" "$name" "$(date)" "$log_file" > "$info_file"
    echo "Started: $name | PID:$pid | $port/$proto"
}

nclist() {
    echo "Listeners:"
    for f in "$NC_DIR"/*.info; do
        [[ -f "$f" ]] || continue
        source "$f"
        kill -0 "$pid" 2>/dev/null && printf "  %s | PID:%s | %s/%s\n" "$name" "$pid" "$port" "$protocol" || _nc_rm "$name"
    done
}

ncstop() {
    [[ -z "$1" ]] && { echo "Usage: ncstop <name|pid|port>"; return 1; }
    local name=$(_nc_find "$1")
    [[ -z "$name" ]] && { echo "Not found: $1"; return 1; }
    source "$(_nc_info "$name")"
    kill "$pid" 2>/dev/null && echo "Stopped: $name"
    _nc_rm "$name"
}

nclog() {
    [[ -z "$1" ]] && { echo "Usage: nclog <name|pid|port> [lines]"; return 1; }
    local name=$(_nc_find "$1")
    [[ -z "$name" ]] && { echo "Not found: $1"; return 1; }
    source "$(_nc_info "$name")"
    if [[ -f "$log_file" ]]; then
        tail -n "${2:-20}" "$log_file"
        printf '\n'
    else
        echo "No log"
    fi
}

ncstopall() {
    local c=0
    for f in "$NC_DIR"/*.info; do
        [[ -f "$f" ]] || continue
        source "$f"
        kill "$pid" 2>/dev/null && ((c++))
        _nc_rm "$name"
    done
    echo "Stopped $c listeners"
}
