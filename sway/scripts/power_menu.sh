#!/bin/bash

SELECTION="$(printf "󰌾 Lock\n󰍃 Log out\n󰤄 Suspend\n Reboot\n Reboot to UEFI\n󰐥 Shutdown" | fuzzel --dmenu -l 6 -w 18 -p "Select an option: ")"

confirm_action() {
    local action="$1"
    CONFIRMATION="$(printf "No\nYes" | fuzzel --dmenu -l 2 -w 18 -p "$action?")"
    [[ "$CONFIRMATION" == *"Yes"* ]]
}

case $SELECTION in
*"󰌾 Lock"*)
    gtklock
    ;;
*"󰍃 Log out"*)
    if confirm_action "Log out"; then
        swaymsg exit
    fi
    ;;
*"󰤄 Suspend"*)
    if confirm_action "Suspend"; then
        systemctl suspend
    fi
    ;;
*" Reboot"*)
    if confirm_action "Reboot"; then
        systemctl reboot
    fi
    ;;
*" Reboot to UEFI"*)
    if confirm_action "Reboot to UEFI"; then
        systemctl reboot --firmware-setup
    fi
    ;;
*"󰐥 Shutdown"*)
    if confirm_action "Shutdown"; then
        systemctl poweroff
    fi
    ;;
esac
