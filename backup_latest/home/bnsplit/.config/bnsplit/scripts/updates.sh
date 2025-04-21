#!/bin/bash

ICON="$HOME/.icons/Papirus/64x64/apps/update-notifier.svg"
BOLD=$(tput bold)
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
CYAN="\e[36m"
MAGENTA="\e[35m"
RESET="\e[0m"

# Check for available updates
echo -ne "${BOLD}${YELLOW}  Checking for updates...${RESET}"
updates=$(yay -Qu 2>&1)
exit_code=$?
echo -e "\r\033[K" # Clear progress line

# Handle check results
if [ $exit_code -eq 1 ]; then
  echo -e "${BOLD}${GREEN}  System is up to date${RESET}"
  notify-send -a "Updates" -i "$ICON" "System Updated" "No updates available"
  exit 0
elif [ $exit_code -ne 0 ]; then
  echo -e "${BOLD}${RED}  Failed to check updates${RESET}"
  notify-send -a "Updates" -i "$ICON" "Update Error" "Failed to check for updates"
  exit 1
fi

# Calculate update count
updates_count=$(echo "$updates" | wc -l)

# Show update notification
notify-send -a "Updates" -i "$ICON" "Updates Available" \
  "<i><b>$updates_count updates found</b></i>" -t 10000

# Display formatted updates
echo -e "${BOLD}${CYAN}  Found ${MAGENTA}$updates_count${CYAN} available updates:${RESET}"
echo -e "${YELLOW}───────────────────────────────────────${RESET}"
echo -e "$updates"
echo -e "${YELLOW}───────────────────────────────────────${RESET}"

# Confirmation prompt
echo -ne "${BOLD}${CYAN}  Proceed with update? ${RESET}[${GREEN}Y${RESET}/${RED}n${RESET}] "
read -r answer

case "${answer,,}" in
y | yes | "")
  echo -e "\n${BOLD}${CYAN}  Starting system update...${RESET}"

  if ! pkexec yay -Su --noconfirm; then
    echo -e "\n${BOLD}${RED}  Update failed - Check output above for details${RESET}"
    notify-send -a "Updates" -i "$ICON" "Update Failed" \
      "Error occurred during update process"
    # Continue script execution instead of exiting
  else
    echo -e "\n${BOLD}${GREEN}  Update completed successfully${RESET}"
    notify-send -a "Updates" -i "$ICON" "Update Complete" \
      "Successfully installed $updates_count updates"
  fi
  ;;
*)
  echo -e "\n${BOLD}${RED}  Update cancelled${RESET}"
  ;;
esac
