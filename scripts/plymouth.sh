#!/bin/bash
source ./scripts/_variables.sh

# --- PLYMOUTH SETUP FUNCTION ---
print_separator "Plymouth Boot Animation Setup"
if confirm "Do you want to install and configure Plymouth?"; then

  # Initramfs Configuration Guide
  echo_arrow "Initramfs Configuration Guide"
  echo -e "${CYAN}1. Open /etc/mkinitcpio.conf${NC}"
  echo -e "${CYAN}2. Find the line starting with: ${GREEN}HOOKS=(base...${NC}"
  echo -e "${CYAN}3. Add ${GREEN}plymouth${NC}"
  echo -e "Example: ${GREEN}HOOKS=(base udev plymouth autodetect ...)${NC}"

  read -rp "Press enter to start editing" _
  sudo vim /etc/mkinitcpio.conf
  sudo mkinitcpio -p linux

  # GRUB Configuration Guide
  echo_arrow "GRUB Configuration Guide"
  echo -e "${CYAN}1. Open /etc/default/grub${NC}"
  echo -e "${CYAN}2. Find the line starting with: ${GREEN}GRUB_CMDLINE_LINUX_DEFAULT=...${NC}"
  echo -e "${CYAN}3. Add these parameters: ${GREEN}splash rd.udev.log_priority=3 vt.global_cursor_default=0${NC}"
  echo -e "Example: ${GREEN}GRUB_CMDLINE_LINUX_DEFAULT=\"quiet splash rd.udev.log_priority=3 vt.global_cursor_default=0\"${NC}"

  read -rp "Press enter to start editing" _
  sudo vim /etc/default/grub
  sudo grub-mkconfig -o /boot/grub/grub.cfg
  echo_success "GRUB configuration updated"

  # Theme Installation
  echo_arrow "Installing custom plymouth themes"
  theme_source="./share/plymouth-themes/"
  if [[ -d "$theme_source" ]]; then
    sudo cp -r "$theme_source"/* /usr/share/plymouth/themes/
    echo_success "Theme files successfully installed to: ${CYAN}/usr/share/plymouth/themes/${GREEN}"

    # Theme Selection
    echo_arrow "Select your Plymouth theme"
    PL_THEME=$(ls /usr/share/plymouth/themes/ | fzf --height=40% --border --ansi \
      --prompt="Choose theme > " --header="Use arrow keys | Enter to select")

    if [[ -n "$PL_THEME" ]]; then
      sudo plymouth-set-default-theme -R "$PL_THEME"
      echo_success "Active theme set to: ${GREEN}$PL_THEME"
    else
      echo_warning "No theme selected - keeping current configuration"
    fi
  else
    echo_error "Theme source directory not found: ${CYAN}$theme_source${RED}"
    echo_error "Please ensure Plymouth theme files are placed in: ${CYAN}$theme_source${RED}"
    echo_error "Download pre-made themes from: ${CYAN}https://github.com/adi1090x/plymouth-themes${RED}"
  fi

  echo_success "Plymouth configuration complete!"
fi
