#!/bin/bash
source ./scripts/_variables.sh

print_separator "Installation of Virtmanager KVM/QEMU"
if confirm "Do you want to install and configure Virtmanager with KVM/QEMU?"; then
  read -rp "Do you want to start? " _
  echo "START KVM/QEMU/VIRT MANAGER INSTALLATION..."

  # ------------------------------------------------------
  # Install Packages
  # ------------------------------------------------------
  sudo pacman -Sy virt-manager virt-viewer qemu-base qemu-desktop vde2 ebtables iptables-nft nftables dnsmasq bridge-utils ovmf swtpm

  # ------------------------------------------------------
  # Edit libvirtd.conf
  # ------------------------------------------------------
  clear
  echo "Configuring libvirtd.conf:"

  CONFIG_LIBVIRTD='unix_sock_group = "libvirt"
unix_sock_rw_perms = "0770"
log_filters="3:qemu 1:libvirt"
log_outputs="2:file:/var/log/libvirt/libvirtd.log"'

  echo -e "${YELLOW}Adding the following lines to /etc/libvirt/libvirtd.conf:${NC}"
  echo -e "${YELLOW}$CONFIG_LIBVIRTD${NC}"
  echo "$CONFIG_LIBVIRTD" | sudo tee -a /etc/libvirt/libvirtd.conf >/dev/null
  echo -e "${GREEN}✔ Configuration has been added to libvirtd.conf.${NC}"

  read -rp "Press any key to review libvirtd.conf: " _
  sudo vim /etc/libvirt/libvirtd.conf

  # ------------------------------------------------------
  # Add user to the group
  # ------------------------------------------------------
  sudo usermod -a -G kvm,libvirt "$(whoami)"

  # ------------------------------------------------------
  # Enable services and modules
  # ------------------------------------------------------
  sudo systemctl enable libvirtd
  sudo systemctl start libvirtd
  sudo modprobe tun

  # ------------------------------------------------------
  # Edit qemu.conf
  # ------------------------------------------------------
  clear
  echo "Configuring qemu.conf:"

  CONFIG_QEMU="user = \"$(whoami)\"
group = \"$(whoami)\""

  echo -e "${YELLOW}Adding the following lines to /etc/libvirt/qemu.conf:${NC}"
  echo -e "${YELLOW}$CONFIG_QEMU${NC}"
  echo "$CONFIG_QEMU" | sudo tee -a /etc/libvirt/qemu.conf >/dev/null
  echo -e "${GREEN}✔ Configuration has been added to qemu.conf.${NC}"

  read -rp "Press any key to review qemu.conf: " _
  sudo vim /etc/libvirt/qemu.conf

  # ------------------------------------------------------
  # Restart Services
  # ------------------------------------------------------
  sudo systemctl restart libvirtd

  # ------------------------------------------------------
  # Autostart Network
  # ------------------------------------------------------
  sudo virsh net-autostart default
fi
