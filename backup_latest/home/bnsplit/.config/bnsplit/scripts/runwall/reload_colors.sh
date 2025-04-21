#!/bin/bash

# ------------------------------
# Configuration
# ------------------------------
CONFIG_DIR="$HOME/.config/bnsplit"
RUNWALL_DIR="$CONFIG_DIR/scripts/runwall"
CACHE_DIR="$CONFIG_DIR/cache"

GTK_THEME_SCRIPT="$CONFIG_DIR/scripts/reload_gtk_theme.sh"

# ------------------------------
# Apply Colors
# ------------------------------
COLOR_INDEX=$(awk 'NR == 1' "$RUNWALL_DIR/color_number")
MAIN_COLOR=$(awk "NR == $COLOR_INDEX" "$CACHE_DIR/genColors/Normal/colors-hex")
"$RUNWALL_DIR/chromafade" --color "$MAIN_COLOR" --config "$RUNWALL_DIR/colors_gradient_templates.jsonc"

# ------------------------------
# Refresh System Components
# ------------------------------
"$GTK_THEME_SCRIPT"
swaync-client -rs

# Flameshot Configuration
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
