#!/bin/bash

NCAT_CTRL_DIR="/tmp/ncat-ctrl"
NCAT_CTRL_CMDS="${NCAT_CTRL_DIR}/cmds"
NCAT_CTRL_OUT="${NCAT_CTRL_DIR}/out"
NCAT_CTRL_OFF="${NCAT_CTRL_DIR}/off"
NCAT_CTRL_PID="${NCAT_CTRL_DIR}/ncat.pid"

nclisten() {
    [[ -z "$1" ]] && { echo "Usage: nclisten <port>"; return 1; }
    command -v ncat >/dev/null || { echo "ncat not found"; return 1; }

    ncctrlstop 2>/dev/null

    mkdir -p "$NCAT_CTRL_DIR"
    : > "$NCAT_CTRL_CMDS" && : > "$NCAT_CTRL_OUT" && echo 0 > "$NCAT_CTRL_OFF"

    # Start ncat in background, use tail -f to feed commands
    tail -f "$NCAT_CTRL_CMDS" | ncat -lvnp "$1" >>"$NCAT_CTRL_OUT" 2>/dev/null &
    disown $! 2>/dev/null

    # Wait briefly for ncat to actually start, then grab its PID
    sleep 0.5
    local ncat_pid=$(pgrep -f "ncat -lvnp $1" | head -1)

    if [[ -z "$ncat_pid" ]]; then
        echo "[!] Failed to start listener"
        rm -rf "$NCAT_CTRL_DIR"
        return 1
    fi

    echo "$ncat_pid" > "$NCAT_CTRL_PID"
    echo "[+] Listener on port $1 (PID $ncat_pid)"
    echo "[*] Waiting for shell..."

    # Background watcher: detect connection via ss
    (
        while kill -0 "$ncat_pid" 2>/dev/null; do
            if ss -tnp 2>/dev/null | grep ":$1" | grep -q "ESTAB"; then
                echo "[+] Shell connected"
                break
            fi
            sleep 0.5
        done
    ) &
    disown $! 2>/dev/null
}

nccmd() {
    [[ -z "$1" ]] && { echo "Usage: nccmd \"<command>\""; return 1; }
    [[ ! -d "$NCAT_CTRL_DIR" ]] && { echo "[!] No session"; return 1; }

    if [[ -f "$NCAT_CTRL_PID" ]]; then
        local pid=$(cat "$NCAT_CTRL_PID")
        kill -0 "$pid" 2>/dev/null || { echo "[!] Session dead"; rm -rf "$NCAT_CTRL_DIR"; return 1; }
    fi

    # Check for established connection
    if ! ss -tnp 2>/dev/null | grep -q "ncat"; then
        echo "[!] No shell connected yet"
        return 1
    fi

    local off=$(cat "$NCAT_CTRL_OFF" 2>/dev/null || echo 0)
    echo "$1" >> "$NCAT_CTRL_CMDS"

    sleep 0.3
    local prev=$off
    for i in {1..20}; do
        local size=$(wc -c < "$NCAT_CTRL_OUT" 2>/dev/null || echo 0)
        [[ $size -gt $prev ]] && { prev=$size; sleep 0.2; } || break
    done

    local new=$(wc -c < "$NCAT_CTRL_OUT" 2>/dev/null || echo 0)
    [[ $new -gt $off ]] && {
        tail -c +$((off + 1)) "$NCAT_CTRL_OUT" | sed -n "2,$ { /.*[$#>][[:space:]]*$/ { q }; p }"
    }
    echo "$new" > "$NCAT_CTRL_OFF"
    echo ""
}

ncctrlstop() {
    if [[ -f "$NCAT_CTRL_PID" ]]; then
        kill "$(cat "$NCAT_CTRL_PID")" 2>/dev/null
    fi
    pkill -f "tail -f $NCAT_CTRL_CMDS" 2>/dev/null
    rm -rf "$NCAT_CTRL_DIR"
    echo "[+] Stopped"
}
