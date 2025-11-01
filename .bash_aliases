alias l='ls -lah'
alias ll='ls -lah'
alias py='python3'

htbip() {
    ip a | grep -oP '10\.10\.\d+\.\d+' | head -n1
}

connvpn() {
    sudo -l >/dev/null

    if [ -z "$1" ]; then
        echo "Usage: connvpn <config_file.ovpn>"
        return 1
    fi
    sudo nohup openvpn --config "$1" </dev/null >/dev/null 2>&1 &

    htbip
}

stopvpn() {
    sudo killall openvpn

    htbip > /dev/null
}

newmachine() {
    local dirname=${1:-ctf_env}

    mkdir -p "$dirname"/{source_code,burp_requests,tmp,shared_volume}
    
    mkdir -p "$dirname"/shared_volume/{data,scripts}

    touch "$dirname"/{ideas,credentials}

    echo "[*] Environment created at $(pwd)/$dirname"

    cd "$(pwd)/$dirname/shared_volume/scripts"

    touch exploit.py

    python -m venv venv

    source venv/bin/activate

    echo "[*] Python environment created at $(pwd)"

    cd ../../

    echo "[*] Restoring hosts"

    restorehosts
}

batdiff() {
    git diff --name-only --relative --diff-filter=d -z $1 | xargs --null bat --diff
}

notify() {
    nohup bash -c 'timeSent=$(date +"%H:%M");sleep "$(($1*60))"; notify-send -a "$timeSent - $(date +"%H:%M")" -u critical " $2"' dummy "$1" "$2" >/dev/null 2>&1 & disown
}

addhost() {
    if [ $# -eq 2 ]; then
        ip=$1
        domain=$2
    elif [ $# -eq 1 ] && [ -n "$targetip" ]; then
        ip=$targetip
        domain=$1
    else
        echo "Usage: addhost <IP> <domain>"
        echo "Or set targetip and run: addhost <domain>"
        return 1
    fi

    echo "$ip $domain" | sudo tee -a /etc/hosts > /dev/null
    cat /etc/hosts
}

restorehosts() {
    echo "127.0.0.1        localhost" | sudo tee /etc/hosts > /dev/null
    echo "::1              localhost" | sudo tee -a /etc/hosts > /dev/null
    cat /etc/hosts
}

settargetip() {
    echo "$1" > ~/.targetip
    export targetip="$1"
}

validate_sha256() {
    local expected="$1"
    local file="$2"

    if [[ -z "$expected" || -z "$file" ]]; then
        echo "Usage: validate_sha256 <expected_sha256> <file>"
        return 1
    fi

    if [[ ! -f "$file" ]]; then
        echo "Error: File '$file' not found."
        return 1
    fi

    local actual
    actual=$(sha256sum "$file" | awk '{print $1}')

    if [[ "$expected" == "$actual" ]]; then
        echo "SHA256 matches!"
        return 0
    else
        echo "SHA256 mismatch!"
        echo "Expected: $expected"
        echo "Actual:   $actual"
        return 1
    fi
}

