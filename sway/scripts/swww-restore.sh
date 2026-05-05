#!/usr/bin/env bash

# Start daemon if not running
pgrep -x awww-daemon >/dev/null || awww-daemon &

# Wait until daemon responds
while ! awww query >/dev/null 2>&1; do
    sleep 0.2
done

# Restore or set fallback
awww restore ||
    awww img ~/.config/sway/wallpaper/train.gif --transition-fps 60
