#!/bin/bash

# ------------------------------
# Configuration
# ------------------------------
CONFIG_DIR="$HOME/.config/bnsplit"
RUNWALL_DIR="$CONFIG_DIR/scripts/runwall"
CACHE_DIR="$CONFIG_DIR/cache"

# ------------------------------
# Argument Check
# ------------------------------
[[ -z "$1" ]] && echo "Error: No wallpaper specified." && exit 1
WALL="$1"

# ------------------------------
# Cleanup and Preparation
# ------------------------------
killall waypaper &>/dev/null
cp "$WALL" "$CACHE_DIR/wallpaper" &

# Extract and Apply Colors
"$RUNWALL_DIR/chromapick" --path "$WALL" --force --reverse

COLOR_INDEX=$(awk 'NR == 1' "$RUNWALL_DIR/color_number")
MAIN_COLOR=$(awk "NR == $COLOR_INDEX" "$CACHE_DIR/genColors/Normal/colors-hex")

"$RUNWALL_DIR/chromafade" --color "$MAIN_COLOR" --config "$RUNWALL_DIR/colors_gradient_templates.jsonc" --force

# ------------------------------
# Refresh System Components
# ------------------------------
"$CONFIG_DIR/scripts/reload_gtk_theme.sh"
swaync-client -rs

# ------------------------------
# Wallpaper Processing
# ------------------------------
process_wallpaper() {
  local input="$1"
  local file_type=$(file --mime-type -b "$input")

  if [[ "$file_type" == "image/png" ]]; then
    cp "$input" "$CACHE_DIR/wallpaper-png"
  else
    magick "$input" -strip -resize 1920x1080^ -gravity center -extent 1920x1080 PNG32:"$CACHE_DIR/wallpaper-png"
  fi
}

if [[ "$(file --mime-type -b "$WALL")" == "image/gif" ]]; then
  process_wallpaper "${WALL}[0]" &
else
  process_wallpaper "$WALL" &
fi

# Flameshot
FLAMESHOT_MAIN_COLOR=$(awk 'NR == 6' "$CONFIG_DIR/colors/colors-hex")
flameshot config --maincolor "$FLAMESHOT_MAIN_COLOR" &

# ------------------------------
# Additional Options
# ------------------------------

# Papirus
PAPIRUS_ICON_NAME=$("$CONFIG_DIR/scripts/papirus_colors_name.py")
gsettings set org.gnome.desktop.interface icon-theme "Papirus-$PAPIRUS_ICON_NAME-Dark"

# Set modified folder icons
folders=("folder-code.svg" "folder-visiting.svg" "folder-applications.svg" "folder-public.svg" "folder-development.svg" "folder-recent.svg" "folder-steam.svg" "folder-kde.svg" "folder-vmware.svg" "folder-cd.svg" "folder-backup.svg")
for dir in ~/.icons/Papirus-Dark/*/places/; do
  for folder in "${folders[@]}"; do
    rm -f "$dir/$folder"
    ln -s "$HOME/.icons/Papirus-$PAPIRUS_ICON_NAME-Dark/32x32/places/$folder" "$dir/$folder"
  done
done

wait
