#!/usr/bin/env python3

import os
import sys


def hex_to_rgb(hex_str):
    hex_str = hex_str.lstrip("#")
    if len(hex_str) != 6:
        raise ValueError(f"Invalid hex color: #{hex_str}")
    try:
        r = int(hex_str[0:2], 16)
        g = int(hex_str[2:4], 16)
        b = int(hex_str[4:6], 16)
    except ValueError:
        raise ValueError(f"Invalid hex color: #{hex_str}")
    return (r, g, b)


def closest_color(target_rgb, color_map):
    min_distance = float("inf")
    closest_name = ""
    for name, rgb in color_map.items():
        # Calculate squared Euclidean distance
        distance = sum((t - c) ** 2 for t, c in zip(target_rgb, rgb))
        if distance < min_distance:
            min_distance = distance
            closest_name = name
    return closest_name


def main():
    color_source_path = os.path.expanduser("~/.config/bnsplit/colors/colors-source")

    try:
        with open(color_source_path, "r") as f:
            first_line = f.readline().strip()
    except FileNotFoundError:
        print(f"Error: File not found at {color_source_path}", file=sys.stderr)
        sys.exit(1)

    if not first_line.startswith("#") or len(first_line) != 7:
        print(f"Error: Invalid color format in file: {first_line}", file=sys.stderr)
        sys.exit(1)

    try:
        target_rgb = hex_to_rgb(first_line)
    except ValueError as e:
        print(e, file=sys.stderr)
        sys.exit(1)

    color_map = {
        "Black": hex_to_rgb("#000000"),
        "Blue": hex_to_rgb("#2196f3"),
        "Bluegrey": hex_to_rgb("#607d8b"),
        "Breeze": hex_to_rgb("#87ceeb"),
        "Brown": hex_to_rgb("#795548"),
        "Carmine": hex_to_rgb("#960018"),
        "Cyan": hex_to_rgb("#00bcd4"),
        "Darkcyan": hex_to_rgb("#008b8b"),
        "Deeporange": hex_to_rgb("#ff5722"),
        "Green": hex_to_rgb("#4caf50"),
        "Grey": hex_to_rgb("#9e9e9e"),
        "Indigo": hex_to_rgb("#3f51b5"),
        "Magenta": hex_to_rgb("#ff00ff"),
        "Nordic": hex_to_rgb("#5e81ac"),
        "Orange": hex_to_rgb("#ff9800"),
        "Palebrown": hex_to_rgb("#d7ccc8"),
        "Paleorange": hex_to_rgb("#ffe0b2"),
        "Pink": hex_to_rgb("#e91e63"),
        "Red": hex_to_rgb("#f44336"),
        "Teal": hex_to_rgb("#009688"),
        "Violet": hex_to_rgb("#9c27b0"),
        "White": hex_to_rgb("#ffffff"),
        "Yellow": hex_to_rgb("#ffeb3b"),
    }

    closest_name = closest_color(target_rgb, color_map)
    print(closest_name)


if __name__ == "__main__":
    main()
