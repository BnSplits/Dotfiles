#!/bin/bash

last_profile=""

gdbus monitor \
  --system \
  --dest net.hadess.PowerProfiles \
  --object-path /net/hadess/PowerProfiles |
  while read -r line; do
    if [[ "$line" == *"ActiveProfile"* ]]; then
      profile=$(echo "$line" | grep -oE "'(performance|balanced|power-saver)'" | tr -d "'")
      if [ "$profile" != "$last_profile" ] && [ -n "$profile" ]; then
        /home/bnsplit/.config/bnsplit/scripts/power_profiles.sh "$profile"
        last_profile="$profile"
      fi
    fi
  done
