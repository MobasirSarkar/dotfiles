#!/usr/bin/env bash

FILE="$HOME/Pictures/screenshot_$(date +%Y%m%d_%H%M%S).png"

# Select area and save
grim -g "$(slurp)" "$FILE"

# Notify
notify-send "Screenshot saved  $FILE"
