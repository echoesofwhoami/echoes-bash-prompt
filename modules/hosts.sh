#!/bin/bash

[[ -f "$HOME/.targetip" ]] && export targetip="$(cat "$HOME/.targetip")"

targetip()    { [[ -f "$HOME/.targetip" ]] && cat "$HOME/.targetip"; }
settargetip() { echo "$1" > ~/.targetip; export targetip="$1"; }

addhost() {
    local ip domain
    if [[ $# -eq 2 ]]; then
        ip="$1"; domain="$2"
    elif [[ $# -eq 1 && -n "$targetip" ]]; then
        ip="$targetip"; domain="$1"
    else
        echo "Usage: addhost [IP] <domain>"; return 1
    fi
    echo "$ip $domain" | sudo tee -a /etc/hosts >/dev/null
    cat /etc/hosts
}

restorehosts() {
    printf '127.0.0.1\tlocalhost\n::1\t\tlocalhost\n' | sudo tee /etc/hosts >/dev/null
    cat /etc/hosts
}

