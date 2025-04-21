#!/bin/bash

# List of colors
colors=(
  adwaita blue breeze carmine darkcyan green indigo nordic palebrown pink teal white yellow black bluegrey brown cyan deeporange grey magenta paleorange red violet yaru
)

source_dir="$HOME/.icons/Papirus-Dark"
# source_dir="/usr/share/icons/Papirus-Dark"

echo "Source directory: $source_dir"

# Check if the source directory exists
if [[ ! -d "$source_dir" ]]; then
  echo "Error: Source directory does not exist."
  exit 1
fi

for color in "${colors[@]}"; do
  up_color="$(echo "$color" | sed 's/^./\U&/')"
  dest_dir="$HOME/ICO/Papirus-$up_color-Dark"

  echo -e "\nCreating directory: $dest_dir"
  mkdir -p "$dest_dir"

  for dir in "$source_dir"/*/; do
    dir_name=$(basename "$dir")
    dest_subdir="$dest_dir/$dir_name"

    echo -e "\nProcessing folder: $dir_name"
    mkdir -p "$dest_subdir"

    for subdir in "$dir"/*/; do
      subdir_name=$(basename "$subdir")
      dest_subsubdir="$dest_subdir/$subdir_name"

      if [[ "$subdir_name" == "places" ]]; then
        echo "  → Copying and renaming icons in $subdir_name"
        mkdir -p "$dest_subsubdir"
        for item in "$subdir"/*; do
          item_name=$(basename "$item")
          if [[ "$item_name" == *"-$color"* ]]; then
            new_name="${item_name//-$color/}"
            echo "    Renaming: $item_name -> $new_name"
            cp "$item" "$dest_subsubdir/$new_name"
          fi
        done
      else
        echo "  → Creating a symbolic link for $subdir_name"
        ln -s "$subdir" "$dest_subsubdir"
      fi
    done
  done

  # Copy and modify index.theme
  if [[ -f "$source_dir/index.theme" ]]; then
    echo -e "\nModifying index.theme for $up_color"
    sed -e "s/^Name=.*/Name=Papirus-$up_color-Dark/" \
      -e "s/^Inherits=.*/Inherits=breeze-dark,hicolor/" \
      "$source_dir/index.theme" >"$dest_dir/index.theme"
  fi

done

echo -e "\nDone!"
