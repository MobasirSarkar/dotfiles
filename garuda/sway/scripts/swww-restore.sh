#!/usr/bin/env bash

# Start daemon if not running
pgrep -x swww-daemon >/dev/null || swww-daemon &

# Wait until daemon responds
while ! swww query >/dev/null 2>&1; do
    sleep 0.2
done

# Restore or set fallback
swww restore ||
    swww img ~/.config/sway/wallpaper/train.gif --transition-fps 60
