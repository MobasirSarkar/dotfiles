#!/usr/bin/env bash
## ---- 💫 https://github.com/JaKooLit (Modified) 💫 ----
## Wallpaper Selector for Hyprland (works with swww or swaybg)

# Wallpaper and theme directories
wallpaperDir="$HOME/Pictures/wallpapers"
themesDir="$HOME/.config/rofi/themes"
currentWallpaper="$HOME/.current_wallpaper"

# Transition settings for swww
FPS=60
TYPE="any"
DURATION=3
BEZIER="0.4,0.2,0.4,1.0"
SWWW_PARAMS="--transition-fps ${FPS} --transition-type ${TYPE} --transition-duration ${DURATION} --transition-bezier ${BEZIER}"

# Ensure wallpaper directory exists
[[ ! -d "$wallpaperDir" ]] && echo "❌ Wallpaper directory not found: $wallpaperDir" && exit 1

# Kill any old swaybg safely
if pidof swaybg >/dev/null; then
  pkill -x swaybg
  sleep 0.3
fi

# Collect image list
mapfile -t PICS < <(find -L "${wallpaperDir}" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) | sort)
[[ ${#PICS[@]} -eq 0 ]] && echo "❌ No images found in $wallpaperDir" && exit 1

# Random option
randomNumber=$(( ($(date +%s) + RANDOM + $$) ))
randomPicture="${PICS[$(( randomNumber % ${#PICS[@]} ))]}"
randomChoice="[${#PICS[@]}] Random"

# Rofi launcher
rofiCommand="rofi -dmenu -theme ${themesDir}/wallpaper-select.rasi -p '🖼 Select Wallpaper:'"

# --- Functions --- #

# Apply wallpaper
set_wallpaper() {
  local img="$1"

  # Save current wallpaper
  ln -sf "$img" "$currentWallpaper"

  if command -v swww &>/dev/null; then
    # Initialize swww if needed
    if ! swww query &>/dev/null; then
      swww init
      sleep 0.5
    fi
    swww img "$img" ${SWWW_PARAMS}

  elif command -v swaybg &>/dev/null; then
    # Use swaybg as fallback (disown to persist)
    nohup swaybg -i "$img" -m fill >/dev/null 2>&1 &

  else
    echo "❌ Neither swww nor swaybg are installed."
    exit 1
  fi
}

# Menu listing
menu() {
  printf "%s\n" "$randomChoice"
  for pic in "${PICS[@]}"; do
    name="$(basename "${pic%.*}")"
    if [[ $pic != *.gif ]]; then
      printf "%s\x00icon\x1f%s\n" "$name" "$pic"
    else
      printf "%s\n" "$name"
    fi
  done
}

# --- Main Logic --- #
main() {
  # Prevent multiple rofi instances
  if pidof rofi >/dev/null; then
    pkill -x rofi
    exit 0
  fi

  choice=$(menu | eval "$rofiCommand")
  [[ -z "$choice" ]] && exit 0

  if [[ "$choice" == "$randomChoice" ]]; then
    set_wallpaper "$randomPicture"
    exit 0
  fi

  for pic in "${PICS[@]}"; do
    if [[ "$(basename "${pic%.*}")" == "$choice" ]]; then
      set_wallpaper "$pic"
      exit 0
    fi
  done

  echo "❌ Image not found for choice: $choice"
  exit 1
}

main
