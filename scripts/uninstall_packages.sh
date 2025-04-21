#!/bin/bash
source ./scripts/_variables.sh

UNINSTALL_FILE="./scripts/_uninstall_pkgs"

if [ ! -f "$UNINSTALL_FILE" ]; then
  echo_error "Uninstall list missing: $UNINSTALL_FILE"
  exit 1
fi

# Read packages
UNINSTALL_PKGS=()
while IFS= read -r pkg; do
  [[ -n "$pkg" ]] && UNINSTALL_PKGS+=("$pkg")
done <"$UNINSTALL_FILE"

print_separator "Package Removal"
if confirm "Uninstall ${#UNINSTALL_PKGS[@]} packages?"; then
  for pkg in "${UNINSTALL_PKGS[@]}"; do
    echo_arrow "Processing $pkg..."

    if pacman -Q "$pkg" &>/dev/null; then
      yay -Rns --noconfirm "$pkg" >/dev/null 2>&1 &&
        echo_success "Removed $pkg" ||
        echo_error "Failed $pkg"
    else
      echo_success "$pkg not installed"
    fi
  done
fi
