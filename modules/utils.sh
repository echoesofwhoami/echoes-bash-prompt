#!/bin/bash

batdiff() { git diff --name-only --relative --diff-filter=d -z "$1" | xargs --null bat --diff; }

notify() {
    nohup bash -c 'ts=$(date +"%H:%M"); sleep "$(($1*60))"; notify-send -a "$ts - $(date +"%H:%M")" -u critical "$2"' _ "$1" "$2" >/dev/null 2>&1 & disown
}

validate_sha256() {
    [[ -z "$1" || -z "$2" ]] && { echo "Usage: validate_sha256 <expected> <file>"; return 1; }
    [[ ! -f "$2" ]] && { echo "File not found: $2"; return 1; }
    local actual=$(sha256sum "$2" | awk '{print $1}')
    [[ "$1" == "$actual" ]] && echo "SHA256 OK" || { echo "SHA256 MISMATCH"; echo "Expected: $1"; echo "Actual:   $actual"; return 1; }
}

tofile() {
    [[ -z "$1" ]] && { echo "Usage: tofile <filename>"; return 1; }
    cat > "$1"
}

newmachine() {
    local dir="${1:-ctf_env}"
    mkdir -p "$dir"/{source_code,data,scripts}
    touch "$dir"/{tmp,credentials,scripts/exploit.py}

    echo "[*] Created: $(pwd)/$dir"

    python -m venv "$dir/scripts/venv" && source "$dir/scripts/venv/bin/activate"
    echo "[*] Python venv activated"

    restorehosts
    cd "$dir" || return
    rm -f ~/.targetip; touch ~/.targetip
    echo "[*] Ready"
}

hashcrack() {
    [[ -z "$1" ]] && { echo "Usage: hashcrack <hash_file>"; return 1; }
    local mode=$(hashcat "$1" --identify | grep -oP '^\s*\K\d+(?=\s*\|)')
    [[ -z "$mode" ]] && { echo "Unknown hash type"; return 1; }
    echo "Mode: $mode"
    hashcat -m "$mode" "$1" /usr/share/seclists/Passwords/Leaked-Databases/rockyou.txt --force
}
