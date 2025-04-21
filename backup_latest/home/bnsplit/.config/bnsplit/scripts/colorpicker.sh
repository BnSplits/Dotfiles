#!/bin/bash

format="$1"
COLOR=$(hyprpicker -a --format="$format")

# Exit if no color picked
[ -z "$COLOR" ] && exit 1

case "$format" in
hex)
  magick_color="$COLOR"
  ;;
rgb)
  IFS=' ' read -r r g b <<<"$COLOR"
  magick_color="rgb($r,$g,$b)"
  ;;
hsl)
  IFS=' ' read -r h s l <<<"$COLOR"
  magick_color="hsl($h,$s,$l)"
  ;;
hsv)
  IFS=' ' read -r h s v <<<"$COLOR"
  magick_color="hsb($h,$s,$v)"
  ;;
cmyk)
  IFS=' ' read -r c m y k <<<"$COLOR"
  magick_color="cmyk($c,$m,$y,$k)"
  ;;
*)
  echo "Unsupported color format: $format"
  exit 1
  ;;
esac

# Sanitize filename by replacing spaces and % with underscores
filename=$(echo "$COLOR" | sed 's/[ %]/_/g')

magick -size 64x64 xc:"$magick_color" "/tmp/${filename}.png"
notify-send "Color Picked" "$COLOR" -i "/tmp/${filename}.png"
