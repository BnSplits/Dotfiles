#!/bin/bash

# Clear the screen
clear

##############################################################################
# Color Definitions
##############################################################################

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

##############################################################################
# Configuration Variables
##############################################################################

# Notification icon path
ICON="/home/bnsplit/.icons/Papirus-Dark/32x32/apps/luckyBackup.svg"

# User configuration
TARGET_USER="bnsplit"
TARGET_HOME="/home/$TARGET_USER"
LOG_FILE="$TARGET_HOME/Dotfiles/backups.log"

# Backup directories
BACKUPS_DIR="$TARGET_HOME/Dotfiles/backups"
DATE=$(date "+%Y-%b-%d_%H-%M-%S")
CURRENT_BACKUP_DIR="$BACKUPS_DIR/$DATE"
LATEST_BACKUP_DIR="$TARGET_HOME/Dotfiles/backup_latest"

##############################################################################
# Items to Backup
##############################################################################
items_to_backup=(
  "$TARGET_HOME/.bash_history"
  "$TARGET_HOME/.bashrc"
  "$TARGET_HOME/.config/ags"
  "$TARGET_HOME/.config/"*.bak
  "$TARGET_HOME/.config/bat"
  "$TARGET_HOME/.config/better-control"
  "$TARGET_HOME/.config/bnsplit"
  "$TARGET_HOME/.config/cava"
  "$TARGET_HOME/.config/chrome-flags.conf"
  "$TARGET_HOME/.config/clipse"
  "$TARGET_HOME/.config/code-flags.conf"
  "$TARGET_HOME/.config/fastfetch"
  "$TARGET_HOME/.config/flameshot"
  "$TARGET_HOME/.config/ghostty"
  "$TARGET_HOME/.config/gpu-screen-recorder/"
  "$TARGET_HOME/.config/gtk-3.0"
  "$TARGET_HOME/.config/gtk-4.0"
  "$TARGET_HOME/.config/hypr"
  "$TARGET_HOME/.config/JetBrains"
  "$TARGET_HOME/.config/kdeconnect"
  "$TARGET_HOME/.config/kitty"
  "$TARGET_HOME/.config/lsd"
  "$TARGET_HOME/.config/mimeapps.list"
  "$TARGET_HOME/.config/nvim"
  "$TARGET_HOME/.config/qalculate"
  "$TARGET_HOME/.config/rofi"
  "$TARGET_HOME/.config/spicetify"
  "$TARGET_HOME/.config/starship.toml"
  "$TARGET_HOME/.config/swaync"
  "$TARGET_HOME/.config/systemd/user/"*.service
  "$TARGET_HOME/.config/systemd/user/"*.timer
  "$TARGET_HOME/.config/waypaper"
  "$TARGET_HOME/.config/yay"
  "$TARGET_HOME/.config/yazi"
  "$TARGET_HOME/.fonts"
  "$TARGET_HOME/.gitconfig"
  "$TARGET_HOME/.icons"
  "$TARGET_HOME/.local/share/applications/better-control-"*.desktop
  "$TARGET_HOME/.local/share/applications/nmtui.desktop"
  "$TARGET_HOME/.local/share/data/Mega Limited"
  "$TARGET_HOME/.local/share/gvfs-metadata"
  "$TARGET_HOME/.themes/"
  "$TARGET_HOME/.tmux"
  "$TARGET_HOME/.tmux.conf"
  "$TARGET_HOME/.Xresources"
  "$TARGET_HOME/.zsh_history"
  "$TARGET_HOME/.zshrc"
  "/etc/makepkg.conf"
  "/etc/sddm.conf.d/autologin.conf"
  "/etc/X11/xorg.conf.d/00-keyboard.conf"
  "/etc/X11/xorg.conf.d/30-touchpad.conf"
  "/root/.bashrc"
  "/usr/local/bin/chromafade"
  "/usr/local/bin/chromapick"
)

##############################################################################
# Notification Function
##############################################################################

send_notification() {
  sudo -u "$TARGET_USER" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/1000/bus" \
    notify-send -a "Backup System" -i "$ICON" "$1" "$2"
}

##############################################################################
# Display Functions
##############################################################################

echo_arrow() { echo -e "${BLUE}=> $1${NC}"; }
echo_success() { echo -e "${GREEN}\u2713 $1${NC}"; }
echo_warning() { echo -e "${YELLOW}\u26A0 $1${NC}"; }
echo_error() { echo -e "${RED}\u2717 $1${NC}\n"; }

print_separator() {
  echo -e "\n${CYAN}##############################${NC}"
  echo -e "${CYAN}# $1${NC}"
  echo -e "${CYAN}##############################${NC}\n"
}

##############################################################################
# Directory Management
##############################################################################

create_backup_dir() {
  if [[ ! -d "$1" ]]; then
    mkdir -p "$1" || {
      echo_error "Failed to create directory: $1"
      exit 1
    }
    chown "$TARGET_USER:$TARGET_USER" "$1" || {
      echo_error "Failed to set ownership for: $1"
      exit 1
    }
  fi
}

setup_directories() {
  create_backup_dir "$BACKUPS_DIR"
  create_backup_dir "$CURRENT_BACKUP_DIR"

  # Ensure log file exists with proper ownership
  touch "$LOG_FILE"
  chown "$TARGET_USER:$TARGET_USER" "$LOG_FILE"
}

##############################################################################
# Backup Functions
##############################################################################

delete_old_backups() {
  print_separator "Checking Existing Backups"
  existing_backups=$(ls -1 "$BACKUPS_DIR" | wc -l)
  MAX_BACKUPS=2

  if [ "$existing_backups" -ge "$MAX_BACKUPS" ]; then
    oldest_backup=$(ls -1t "$BACKUPS_DIR" | tail -n 1)
    echo_arrow "Deleting oldest backup: $oldest_backup"
    rm -rf "$BACKUPS_DIR/$oldest_backup" || {
      echo_error "Failed to delete $oldest_backup"
      exit 1
    }
  fi
}

save_dconf_settings() {
  print_separator "Saving dconf settings"
  DCONF_SETTINGS_FILE="$TARGET_HOME/Dotfiles/share/dconf-settings-backup.dconf"
  echo_arrow "Exporting dconf settings..."
  if sudo -u "$TARGET_USER" dconf dump / >"$DCONF_SETTINGS_FILE"; then
    echo_success "dconf settings saved"
    chmod 600 "$DCONF_SETTINGS_FILE"
    chown "$TARGET_USER:$TARGET_USER" "$DCONF_SETTINGS_FILE"
  else
    echo_error "Failed to export dconf settings"
    exit 1
  fi
}

save_libvirt_vms() {
  print_separator "Saving libvirt VMs"
  DUMP_FOLDER="$TARGET_HOME/Dotfiles/share/libvirt-vms"
  create_backup_dir "$DUMP_FOLDER"

  echo_arrow "Cleaning old XMLs..."
  rm -f "$DUMP_FOLDER"/*

  echo_arrow "Backing up VM configurations..."
  for vm in $(virsh list --all --name); do
    virsh dumpxml "$vm" >"$DUMP_FOLDER/${vm}.xml"
    echo "Saved VM config: $(basename "$vm")"
  done
  chown -R "$TARGET_USER:$TARGET_USER" "$DUMP_FOLDER"
}

backup_items() {
  print_separator "Backing Up Files and Folders"
  for item in "${items_to_backup[@]}"; do
    echo_arrow "Processing: $item"
    if ! rsync -aR "$item" "$CURRENT_BACKUP_DIR"; then
      echo_warning "Skipping non-existent item: $item"
    fi
  done
}

save_packages() {
  print_separator "Backing up installed packages..."
  if pacman -Qqe >"$TARGET_HOME/Dotfiles/scripts/_install_pkgs"; then
    echo_success "Package list saved successfully!"
  else
    echo_error "Failed to save package list."
  fi
}

update_latest_backup() {
  print_separator "Updating Latest Backup"
  echo_arrow "Removing old latest backup..."
  rm -rf "$LATEST_BACKUP_DIR" 2>/dev/null

  echo_arrow "Creating new latest backup..."
  create_backup_dir "$LATEST_BACKUP_DIR"

  echo_arrow "Syncing current backup..."
  rsync -a "$CURRENT_BACKUP_DIR/" "$LATEST_BACKUP_DIR/"
}

refresh_sddm_themes() {
  print_separator "Refreshing SDDM Themes"
  echo_arrow "Syncing SDDM themes..."
  create_backup_dir "$TARGET_HOME/Dotfiles/share/sddm-themes"

  rsync -aR "/usr/share/sddm/themes/" "$TARGET_HOME/Dotfiles/share/sddm-themes/" || {
    echo_error "SDDM theme sync failed"
    exit 1
  }
  echo_success "SDDM themes updated"
}

##############################################################################
# Main Execution
##############################################################################

# Check root privileges
if [[ $EUID -ne 0 ]]; then
  echo -e "${RED}ERROR: This script must be run as root${NC}"
  echo -e "Use: ${CYAN}sudo $0${NC}"
  exit 1
fi

# Initialize backup process
send_notification "Backup Started" "System backup process is beginning..."
print_separator "Starting System Backup"
echo_success "Backup process started at $(date)"

# Setup environment
setup_directories
START_TS=$(date +%s)
START=$(date +'%Y-%m-%d %H:%M:%S')

# Execute backup steps
delete_old_backups
save_packages
save_dconf_settings
save_libvirt_vms
backup_items
update_latest_backup
refresh_sddm_themes

# Finalize process
END_TS=$(date +%s)
END=$(date +'%Y-%m-%d %H:%M:%S')
DURATION=$((END_TS - START_TS))

# Convert duration to HH:MM:SS
HRS=$((DURATION / 3600))
MIN=$(((DURATION % 3600) / 60))
SEC=$((DURATION % 60))
DURATION_FMT=$(printf "%02d:%02d:%02d" "$HRS" "$MIN" "$SEC")

echo -e "${CYAN}\n───────────────────────────────────────────────────────────────────────────────"
echo_success "Backup process completed at $END (Duration: $DURATION_FMT)"
send_notification "Backup Completed" "System backup finished successfully!"

# Log completion
tmpfile=$(mktemp)
{
  echo "┌───────────────────────────────────────────────┐"
  echo "│  === BACKUP STARTED: $START ===  │"
  echo "│ === BACKUP COMPLETED: $END === │"
  echo "│              TimeSpent: $DURATION_FMT              │"
  echo -e "└───────────────────────────────────────────────┘\n"
  cat "$LOG_FILE"
} >"$tmpfile"

chown "$TARGET_USER:$TARGET_USER" "$tmpfile"
mv "$tmpfile" "$LOG_FILE"
