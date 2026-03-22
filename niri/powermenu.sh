#!/bin/sh

# Define the path to your custom lock script
# The tilde (~) will be expanded to the user's home directory.
LOCK_SCRIPT=~/.config/niri/lock_with_effects.sh

choice=$(printf "Lock\nLogout\nSuspend\nReboot\nShutdown" | fuzzel --dmenu)

case "$choice" in
    Lock) "$LOCK_SCRIPT" ;; # CORRECTED: Removed the problematic "./" prefix
    Logout) niri msg action quit ;;
    Suspend) systemctl suspend ;;
    Reboot) systemctl reboot ;;
    Shutdown) systemctl poweroff ;;
esac
