#!/bin/bash

VPN_DIR="$HOME/vpn"

vpnfilemv() {
    mkdir -p "$VPN_DIR"
    mv ~/Downloads/*.ovpn "$VPN_DIR/" 2>/dev/null && echo "Moved .ovpn files to $VPN_DIR" || echo "No .ovpn files in ~/Downloads"
}

vpns() { ls -lah "$VPN_DIR"; }

htbip() { ip a | grep -oP '10\.10\.\d+\.\d+' | head -n1; }

connvpn() {
    sudo -l >/dev/null
    local files=("$VPN_DIR"/*.ovpn)

    [[ ! -d "$VPN_DIR" || ! -f "${files[0]}" ]] && { echo "No .ovpn files in $VPN_DIR"; return 1; }

    if [[ -z "$1" ]]; then
        echo "VPN files:"
        local i=1
        for f in "${files[@]}"; do [[ -f "$f" ]] && echo "  $((i++))) $(basename "$f")"; done
        read -rp "Select (1-$((i-1))): " choice
        [[ ! "$choice" =~ ^[0-9]+$ || "$choice" -lt 1 || "$choice" -ge "$i" ]] && { echo "Invalid"; return 1; }
        selected="${files[$((choice-1))]}"
    else
        selected="$1"
    fi

    [[ ! -f "$selected" ]] && { echo "Not found: $selected"; return 1; }
    echo "Connecting to $(basename "$selected")..."
    sudo nohup openvpn --config "$selected" </dev/null >/dev/null 2>&1 &
    htbip
}

stopvpn() { sudo killall openvpn 2>/dev/null; }
