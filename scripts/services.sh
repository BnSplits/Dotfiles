#!/bin/bash
source ./scripts/_variables.sh

# Network
print_separator "Network"
if confirm "Do you want to enable Network Manager?"; then
  sudo systemctl enable --now NetworkManager
fi

# Pipewire
print_separator "Pipewire"
if confirm "Do you want to enable pipewire?"; then
  sudo systemctl enable --now pipewire pipewire-pulse wireplumber
fi

# Bluetooth setup
print_separator "Bluetooth"
if confirm "Do you want to configure Bluetooth?"; then
  sudo systemctl enable --now bluetooth.service
fi

# Docker Configuration
print_separator "Configuring Docker"
if confirm "Do you want to configure Docker?"; then
  echo_arrow "Enabling Docker service..."
  sudo systemctl enable --now docker &&
    echo_success "Docker service enabled and started" &&
    echo_arrow "adding user to docker group" &&
    sudo usermod -aG docker "$USER" &&
    echo_success "user added"
fi

# Enable user custom services
print_separator "$USER custom services"
if confirm "Do you want to enable user's custom services?"; then
  for service_file in "$HOME/.config/systemd/user"/*.service; do
    base_name=$(basename "$service_file" .service)

    timer_file="$HOME/.config/systemd/user/$base_name.timer"

    if [ -f "$timer_file" ]; then
      echo "Enabling timer: $base_name.timer"
      systemctl --user enable --now "$base_name.timer"
    else
      echo "Enabling service: $base_name.service"
      systemctl --user enable --now "$base_name.service"
    fi
  done
fi
