#!/bin/bash
source ./scripts/_variables.sh

PKG_FILE="./scripts/_install_pkgs"

if [ ! -f "$PKG_FILE" ]; then
  echo_error "Package file $PKG_FILE not found"
  exit 1
fi

# Read packages into array
INSTALL_PKGS=()
while IFS= read -r pkg; do
  [[ -n "$pkg" ]] && INSTALL_PKGS+=("$pkg")
done <"$PKG_FILE"

# Install base packages
print_separator "Installing base packages"
if confirm "Do you want to install base packages?"; then
  yay -Sy
  for pkg in "${INSTALL_PKGS[@]}"; do
    echo_arrow "Checking $pkg..."

    if pacman -Q "$pkg" &>/dev/null; then
      echo_success "$pkg is already installed"
    else
      echo_arrow "Installing $pkg..."
      if yay -S --noconfirm --quiet "$pkg" >/dev/null 2>&1; then
        echo_success "$pkg installed"
      else
        echo_error "$pkg not installed"
      fi
    fi
  done
fi
