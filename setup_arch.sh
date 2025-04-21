#!/bin/bash
source ./scripts/_variables.sh

# NON root user check
if [ "$(id -u)" -eq 0 ]; then
  echo "This script must NOT be run as root"
  exit 1
fi

# --- CONFIRMATION HANDLING ---
clear
read -rp "$(echo -e "${BLUE}=> Enable confirmation before each operation? ${YELLOW}(Y/n) ${NC}")" enable_confirm
if [[ "${enable_confirm,,}" =~ ^(y|)$ ]]; then
  confirm() {
    local message="$1"
    read -rp "$(echo -e "${YELLOW}$message (y/N) ${NC}")" response
    if [[ "$response" != "y" ]]; then
      echo_warning "Operation skipped."
      return 1
    fi
    return 0
  }
else
  confirm() {
    return 0
  }
fi
export -f confirm

SCRIPT_DIR="$(dirname "$(realpath "$0")")"

# --- DIRECTORY CHECK ---
if [[ "$PWD" != "$SCRIPT_DIR" ]]; then
  echo -e "${RED}╔══════════════════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${RED}║  Be sure to be in the same directory as the script before launching it!  ║${NC}"
  echo -e "${RED}╚══════════════════════════════════════════════════════════════════════════╝${NC}"
  exit 1
fi
cd "$SCRIPT_DIR" || exit 1

# --- CHECKING FOR YAY ---
if ! command -v yay &>/dev/null; then
  echo_error "yay is not installed. Install yay before continuing."

  if confirm "Do you want to install yay?"; then
    YAY_DIR="/tmp/yay-$(date '+%Y-%m-%d_%H-%M-%S')"

    echo_arrow "Installing required dependencies..."
    sudo pacman -Syu --needed base-devel git || {
      echo_error "Failed to install dependencies."
      exit 1
    }

    echo_arrow "Cloning yay repository..."
    git clone --depth=1 https://aur.archlinux.org/yay.git "$YAY_DIR" || {
      echo_error "Failed to clone yay repository."
      exit 1
    }

    cd "$YAY_DIR" || {
      echo_error "Failed to enter directory: $YAY_DIR"
      exit 1
    }

    echo_arrow "Building and installing yay..."
    makepkg -si || {
      echo_error "Failed to build and install yay."
      exit 1
    }

    cd - || exit

    echo_success "yay has been successfully installed."
  else
    echo_error "Installation aborted by user."
    exit 1
  fi
  clear
fi

# --- CONFIGURATION STEPS ---
./scripts/remove_olddots.sh
./scripts/update_db.sh
./scripts/install_special.sh
./scripts/uninstall_packages.sh
./scripts/install_packages.sh
./scripts/virtmanager.sh
./scripts/misc.sh
./scripts/services.sh
./scripts/restore_backup.sh
./scripts/git_config.sh
./scripts/grub.sh
./scripts/sddm.sh
./scripts/plymouth.sh

# --- FINAL STEPS ---
# Delete go folder created by yay and ags installation
[[ -d $HOME/go ]] && sudo rm -rf "$HOME/go"

# Reboot
print_separator "It is recommended to restart the system"
read -rp "$(echo -e "${BLUE}=> Do you want to restart? ${YELLOW}(Y/n) ${NC}") " restart
if [[ "${restart,,}" =~ ^(y|)$ ]]; then
  sudo systemctl reboot
fi
