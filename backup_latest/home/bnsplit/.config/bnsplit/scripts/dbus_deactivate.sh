#!/bin/bash

# Find and process GNOME application files with privilege elevation only when needed
find /usr/share/applications -type f -print0 | while IFS= read -r -d $'\0' file; do
  if grep -q "DBusActivatable=true" "$file"; then
    echo "Modifying: $file"
    sudo sed -i 's/DBusActivatable=true/DBusActivatable=false/g' "$file"
  fi

  if grep -q "^Exec=gapplication launch org.gnome" "$file"; then
    echo "Updating Exec command in: $file"
    sudo sed -i -E 's|Exec=gapplication launch org\.gnome\.([a-zA-Z0-9_-]+).*|Exec=gnome-\L\1 %U|g' "$file"
  fi

done

sudo update-desktop-database

echo "Operation completed"
