#!/bin/bash

settime() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: settime <datetime|restore>"
        echo "  datetime: \"2026-01-27 12:52:00\" - disable NTP and set time"
        echo "  restore: enable NTP synchronization"
        return 1
    fi
    
    if [[ "$1" == "restore" ]]; then
        echo "Enabling NTP synchronization..."
        sudo timedatectl set-ntp true
        echo "NTP enabled"
        timedatectl status
    else
        echo "Setting time to: $1"
        sudo timedatectl set-ntp false
        sudo timedatectl set-time "$1"
        echo "Time set, NTP disabled"
        timedatectl status
    fi
}
