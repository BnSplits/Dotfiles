#!/bin/bash

SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
ICON_ABORTED_PATH="$HOME/.icons/Papirus/32x32/emblems/emblem-unreadable.svg"
OBSIDIAN_DIR="$HOME/Obsidian/99 Assets"
mkdir -p "$SCREENSHOT_DIR" "$OBSIDIAN_DIR"

timestamp="$(date +'%Y-%m-%d_%Hh%Mm%Ss')"
FILE_NAME="${timestamp}.png"
FILE_PATH=""

swaync-client --dnd-on

take_screenshot() {
  local mode="$1"
  local path="$2"

  FILE_PATH="$path"

  export XDG_CURRENT_DESKTOP=sway
  flameshot "$mode" --path "$path" -c

  swaync-client --dnd-off

  if [[ -s "$FILE_PATH" ]]; then
    notify-send -a "Screenshot" "Screenshot Taken" "<i>Saved and copied to clipboard</i>\n<b>$FILE_PATH</b>" -i "$FILE_PATH" -t 5000
  else
    notify-send -a "Screenshot" "Screenshot Aborted" "The screenshot capture was cancelled." -i "$ICON_ABORTED_PATH" -t 5000
  fi
}

case "$1" in
"record-obs")
  obs --startrecording --minimize-to-tray &
  ;;
"part")
  take_screenshot "gui" "$SCREENSHOT_DIR/$FILE_NAME"
  ;;
"full")
  take_screenshot "full" "$SCREENSHOT_DIR/$FILE_NAME"
  ;;
"obsidian")
  take_screenshot "gui" "$OBSIDIAN_DIR/$FILE_NAME"
  ;;
"kdeconnect")
  take_screenshot "gui" "$SCREENSHOT_DIR/$FILE_NAME"

  if [[ ! -s "$SCREENSHOT_DIR/$FILE_NAME" ]]; then
    exit 1
  fi

  connected_devices=$(kdeconnect-cli -a | grep -oP '(?<=: )[a-zA-Z0-9_-]+(?= \(paired and reachable\))')

  if [[ -z "$connected_devices" ]]; then
    notify-send -a "Screenshot" "Error" "No connected KDE Connect devices found." -t 5000
    exit 1
  fi

  for device in $connected_devices; do
    kdeconnect-cli --share "$SCREENSHOT_DIR/$FILE_NAME" -d "$device"
  done
  ;;
*)
  echo "Invalid command: $1" >&2
  echo "Available commands: record-obs, part, full, obsidian, kdeconnect"
  exit 1
  ;;
esac

exit 0
