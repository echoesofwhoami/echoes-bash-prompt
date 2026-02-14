#!/bin/bash

fuzz() {
    command -v feroxbuster >/dev/null || { echo "feroxbuster not found"; return 1; }

    local target="" cookies="" wordlist_type=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -c|--cookies) cookies="$2"; shift 2 ;;
            -*) echo "Unknown option: $1"; return 1 ;;
            *)  if [[ -z "$target" ]]; then
                    target="$1"
                elif [[ -z "$wordlist_type" ]]; then
                    wordlist_type="$1"
                else
                    echo "Too many arguments"; return 1
                fi
                shift ;;
        esac
    done

    [[ -z "$target" ]] && { echo "Usage: fuzz <target> [wordlist_type] [-c cookies]"; return 1; }

    [[ "$target" != http://* && "$target" != https://* ]] && target="http://$target"

    local wordlist

    case "$wordlist_type" in
        "medium")
            wordlist="/usr/share/seclists/Discovery/Web-Content/DirBuster-2007_directory-list-2.3-medium.txt"
            ;;
        *)
            wordlist="/usr/share/seclists/Discovery/Web-Content/common.txt"
            ;;
    esac

    local cmd=(feroxbuster --url "$target" --wordlist "$wordlist" --redirects --burp --silent -g --no-state)

    [[ -n "$cookies" ]] && cmd+=(-b "$cookies")

    "${cmd[@]}"
}

subfuzz() {
    command -v ffuf >/dev/null || { echo "ffuf not found"; return 1; }

    local domain="" wordlist="/usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -w|--wordlist) wordlist="$2"; shift 2 ;;
            -*) echo "Unknown option: $1"; return 1 ;;
            *)  domain="$1"; shift ;;
        esac
    done

    [[ -z "$domain" ]] && { echo "Usage: subfuzz <domain> [-w wordlist]"; return 1; }

    ffuf -u "http://FUZZ.${domain}" -w "$wordlist" -mc 200,301,302,403
}
