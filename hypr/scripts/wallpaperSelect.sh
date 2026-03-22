#!/usr/bin/env bash
# ----------------------------------------
# 🖼 Restore last wallpaper on Hyprland startup
# Works with both swww and swaybg
#----------------------------------------

sleep 1

WALL="$HOME/.current_wallpaper"

# Exit if no wallpaper has been set yet
if [[ ! -f "$WALL" ]]; then
  echo "No wallpaper saved yet at $WALL"
  exit 0
fi

# If swww exists, use it (preferred)
if command -v swww &>/dev/null; then
  # Initialize if not running
  if ! swww query &>/dev/null; then
    swww init
    sleep 0.3
  fi

  # Instantly set wallpaper (no transition)
  swww img "$WALL" --transition-type simple --transition-duration 0

# Otherwise, fallback to swaybg
elif command -v swaybg &>/dev/null; then
  nohup swaybg -i "$WALL" -m fill >/dev/null 2>&1 &

else
  echo "❌ Neither swww nor swaybg is installed."
  exit 1
fi
