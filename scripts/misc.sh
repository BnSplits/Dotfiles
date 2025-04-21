#!/bin/bash
source ./scripts/_variables.sh

# Default shell
print_separator "ZSH as default shell"
if confirm "Do you want to select ZSH as your default SHELL ?"; then
  sudo chsh "$USER" -s /bin/zsh
fi

# Power button
print_separator "Power Button"
if confirm "Change power button action to do nothing?"; then
  echo "Press Enter to add the following line to /etc/systemd/logind.conf:"
  echo "HandlePowerKey=ignore"
  read -r _
  sudo vim /etc/systemd/logind.conf
fi

# Visudo
print_separator "Editing sudoers file"
if confirm "Do you want to edit the sudoers file?"; then
  echo -e "${CYAN}1. Scroll to the end of the file.${NC}"
  echo -e "${CYAN}2. Add the following line: ${GREEN}$USER ALL=(ALL) NOPASSWD: /usr/bin/pacman -Sy${NC}"
  echo -e "${CYAN}3. Then add this line: ${GREEN}$USER ALL=(ALL) NOPASSWD: /home/bnsplit/.config/bnsplit/scripts/save.sh${NC}"
  read -rp "Press enter to open visudo..." _
  sudo visudo
fi
