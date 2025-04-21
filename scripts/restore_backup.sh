#!/bin/bash
source ./scripts/_variables.sh

# Backup restoration
ARCHIVE_BACKUP="./backup_latest/"
if [ -d "$ARCHIVE_BACKUP" ]; then
  print_separator "Restoring backup"
  if confirm "Do you want to restore the backup?"; then
    echo_arrow "Restoring files with preserved permissions..."
    sudo rsync -avh "$ARCHIVE_BACKUP/" "/"
    echo_success "Restoration complete"
  fi
else
  echo_warning "No backup archive folder found"
fi

# DCONF config restoration
print_separator "DCONF restoration"
if confirm "Do you want to restore dconf config?"; then
  dconf load / <"./share/dconf-settings-backup.dconf"
fi

# CRON restoration
print_separator "Crontab restoration"
USER_CRON="./share/crontab-bnsplit"
ROOT_CRON="./share/crontab-root"
if confirm "Do you want to restore crontabs?"; then
  if [ -f "$USER_CRON" ]; then
    echo_arrow "Restoration of $USER's crontab"
    crontab -u "$USER" "$USER_CRON"

    echo_arrow "Restoration of root's crontab"
    sudo crontab -u root "$ROOT_CRON"
  fi
fi

# VM restoration
print_separator "QEMU/Virtmanager VMs restoration"
DUMP_FOLDER="./share/libvirt-vms"
if confirm "Do you want to restore your libvirt Virtual Machines?"; then
  echo_arrow "Restoring libvirt VMs..."
  for xml in "$DUMP_FOLDER"/*.xml; do
    echo "Defining VM from file: $xml"
    sudo virsh define "$xml"
  done
  echo_success "VM restoration complete"
fi
