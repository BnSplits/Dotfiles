#!/bin/bash
source ./scripts/_variables.sh

# Tmux tpm
print_separator "Installing tmux plugin manager"
if confirm "Do you want to install tpm (Tmux)?"; then
  echo_arrow "Tpm installation..."
  [[ ! -d "$HOME/.tmux/plugins/tpm" ]] &&
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm || echo "TPM seems to be already installed!"
fi

# Spicetify
print_separator "Installing spicetify"
if confirm "Do you want to install Spicetify?"; then
  echo_arrow "Installation of Spicetify..."
  curl -fsSL https://raw.githubusercontent.com/spicetify/cli/main/install.sh | sh
fi

# Hyprls (Hyprland LSP)
print_separator "Installing Hyprland LSP(hyprls)"
if confirm "Do you want to install Hyprls (Hyprland LSP)?"; then
  go install github.com/hyprland-community/hyprls/cmd/hyprls@latest
fi

# Live server
print_separator "Installing live-server with pnpm"
if confirm "Do you want to install globally Live Server with npm"; then
  pnpm setup
  pnpm i -g live-server
fi

# Rustup
print_separator "Installing Rust+Rustup+Cargo"
if confirm "Do you want to install rust+rustup+cargo?"; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  chmod +x "$HOME"/.cargo/env
fi

# Hypr-dynamic-cursors
print_separator "Installing Hyprland hypr-dynamic-cursors plugin"
if confirm "Do you want to install hypr-dynamic-cursors plugin?"; then
  hyprpm update
  hyprpm add https://github.com/virtcode/hypr-dynamic-cursors
  hyprpm reload -n
  hyprpm enable dynamic-cursors
fi

# # Install Megasync
# print_separator "Installing Megasync"
# if confirm "Do you want to install Megasync?"; then
#   megasync_pkg="megasync-x86_64.pkg.tar.zst"
#   megasync_url="https://mega.nz/linux/repo/Arch_Extra/x86_64/$megasync_pkg"
#   cd $HOME/Downloads
#
#   if [ ! -f "$megasync_pkg" ]; then
#     echo_arrow "Downloading Megasync..."
#     wget "$megasync_url" || {
#       echo_error "Failed to download Megasync"
#       exit 1
#     }
#   fi
#
#   echo_arrow "Installing Megasync..."
#   sudo pacman -U "$megasync_pkg" --noconfirm || echo_error "Failed to install Megasync"
#   rm -f "$megasync_pkg"
# fi
