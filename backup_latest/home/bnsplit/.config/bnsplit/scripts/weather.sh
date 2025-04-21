#!/bin/bash

# Get location (latitude, longitude)
LOCATION=$(curl -s ipinfo.io/loc) || {
  echo "Location lookup failed" >&2
  exit 1
}

# Get city name
CITY=$(curl -s ipinfo.io/city) || {
  echo "City lookup failed" >&2
  exit 1
}

# Get weather data
WEATHER_DATA=$(curl -s "https://api.open-meteo.com/v1/forecast?latitude=${LOCATION%,*}&longitude=${LOCATION#*,}&current_weather=true") || {
  echo "Weather API failed" >&2
  exit 1
}

# Extract required information
TEMP=$(echo "$WEATHER_DATA" | jq -r '.current_weather.temperature | round')
WEATHER_CODE=$(echo "$WEATHER_DATA" | jq -r '.current_weather.weathercode')

# Check if values are valid
[[ -n "$TEMP" && -n "$WEATHER_CODE" ]] || {
  echo "Invalid weather data" >&2
  exit 1
}

# Map weather codes to states, icons, and icon names
declare -A WEATHER_MAP=(
  [0]=" Clear"
  [1]="󰖕 Partly Cloudy"
  [2]="󰖕 Cloudy"
  [3]=" Overcast"
  [45]="󰖑 Fog"
  [48]="󰖑 Dense Fog"
  [51]=" Light Drizzle"
  [53]=" Drizzle"
  [55]=" Heavy Drizzle"
  [61]=" Light Rain"
  [63]=" Rain"
  [65]=" Heavy Rain"
  [71]=" Light Snow"
  [73]=" Snow"
  [75]="󰼶 Heavy Snow"
  [95]=" Thunderstorm"
  [99]=" Severe Thunderstorm"
)

declare -A WEATHER_ICON_MAP=(
  [0]="weather-clear-symbolic"
  [1]="weather-few-clouds-symbolic"
  [2]="weather-overcast-symbolic"
  [3]="weather-overcast-symbolic"
  [45]="weather-fog-symbolic"
  [48]="weather-fog-symbolic"
  [51]="weather-showers-scattered-symbolic"
  [53]="weather-showers-scattered-symbolic"
  [55]="weather-showers-symbolic"
  [61]="weather-showers-scattered-symbolic"
  [63]="weather-showers-symbolic"
  [65]="weather-showers-symbolic"
  [71]="weather-snow-symbolic"
  [73]="weather-snow-symbolic"
  [75]="weather-snow-symbolic"
  [95]="weather-storm-symbolic"
  [99]="weather-storm-symbolic"
)

WEATHER_ENTRY=${WEATHER_MAP[$WEATHER_CODE]:-"🌡 Unknown"}
WEATHER_ICON=$(awk '{print $1}' <<<"$WEATHER_ENTRY")
WEATHER_STATE=$(awk '{ $1=""; print substr($0,2) }' <<<"$WEATHER_ENTRY")
ICON_NAME=${WEATHER_ICON_MAP[$WEATHER_CODE]:-"weather-severe-alert-symbolic"}

# Parse command-line arguments
output_file=""
components=()

for arg in "$@"; do
  if [[ "$arg" == --output=* ]]; then
    output_file="${arg#*=}"
  else
    components+=("$arg")
  fi
done

# Expand tilde in output path if provided
[[ -n "$output_file" ]] && output_file="${output_file/#\~/$HOME}"

# Validate components
[[ ${#components[@]} -gt 0 ]] || {
  echo "No components specified" >&2
  exit 1
}

# Build output line
output_parts=()
for component in "${components[@]}"; do
  case "$component" in
  city) output_parts+=("$CITY") ;;
  temp) output_parts+=("${TEMP}°C") ;;
  weather) output_parts+=("$WEATHER_ENTRY") ;;
  weather_icon) output_parts+=("$WEATHER_ICON ‎") ;;
  weather_state) output_parts+=("$WEATHER_STATE") ;;
  icon_name) output_parts+=("$ICON_NAME") ;;
  *)
    echo "Invalid component: $component" >&2
    exit 1
    ;;
  esac
done

# Output handling
if [[ -n "$output_file" ]]; then
  mkdir -p "$(dirname "$output_file")" || {
    echo "Failed to create output directory" >&2
    exit 1
  }
  echo "${output_parts[*]}" >"$output_file" || {
    echo "Failed to write output file" >&2
    exit 1
  }
else
  # Directly echo the output if no -output specified
  echo "${output_parts[*]}"
fi
