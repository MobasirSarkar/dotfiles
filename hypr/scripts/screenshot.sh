#!/usr/bin/env bash

# Filename with timestamp
FILE="$HOME/Pictures/screenshot_$(date +%Y%m%d_%H%M%S).png"

# Take fullscreen screenshot
grim "$FILE"

# Send notification via swaync
notify-send "Screenshot saved $FILE"
