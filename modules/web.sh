#!/bin/bash

fuzz() {
    local target="" cookies=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -c|--cookies) cookies="$2"; shift 2 ;;
            -*) echo "Unknown option: $1"; return 1 ;;
            *)  target="$1"; shift ;;
        esac
    done

    [[ -z "$target" ]] && { echo "Usage: fuzz <target> [-c cookies]"; return 1; }
    command -v feroxbuster >/dev/null || { echo "feroxbuster not found"; return 1; }

    local cmd=(feroxbuster --url "$target"
        --wordlist /usr/share/seclists/Discovery/Web-Content/common.txt
        --redirects --burp --quiet -g)

    [[ -n "$cookies" ]] && cmd+=(-b "$cookies")

    "${cmd[@]}"
}

subfuzz() {
    local domain="" wordlist="/usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -w|--wordlist) wordlist="$2"; shift 2 ;;
            -*) echo "Unknown option: $1"; return 1 ;;
            *)  domain="$1"; shift ;;
        esac
    done

    [[ -z "$domain" ]] && { echo "Usage: subfuzz <domain> [-w wordlist]"; return 1; }
    command -v ffuf >/dev/null || { echo "ffuf not found"; return 1; }

    ffuf -u "http://FUZZ.${domain}" -w "$wordlist" -mc 200,301,302,403
}
