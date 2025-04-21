#!/usr/bin/env bash

COMMAND=$1

handle_next() {
  local current_ws=$(hyprctl -j activeworkspace)
  local current_id=$(echo "$current_ws" | jq '.id')
  local window_count=$(echo "$current_ws" | jq '.windows')

  local workspaces_json=$(hyprctl -j workspaces | jq 'map(select(.id >= 1)) | sort_by(.id)')
  local next_id=$(echo "$workspaces_json" | jq --argjson curr "$current_id" '
        [.[].id] | 
        map(select(. > $curr)) | 
        if length > 0 then first else $curr + 1 end
  ')

  local next_window_count=$(echo "$workspaces_json" | jq --argjson next "$next_id" '
    [.[] | select(.id == $next)] | 
    if length > 0 then .[0].windows else 0 end
  ')

  if [[ $window_count -eq 1 && $next_window_count -eq 0 ]]; then
    exit 0
  fi

  hyprctl dispatch movetoworkspace "$next_id"
}

handle_previous() {
  local current_ws=$(hyprctl -j activeworkspace)
  local current_id=$(echo "$current_ws" | jq '.id')
  local window_count=$(echo "$current_ws" | jq '.windows')

  [[ $window_count -eq 0 ]] && exit 0

  local workspaces_json=$(hyprctl -j workspaces | jq 'map(select(.id >= 1)) | sort_by(.id)')
  local prev_id=$(echo "$workspaces_json" | jq --argjson curr "$current_id" '
        [.[].id] | 
        sort | 
        map(select(. < $curr)) | 
        if length > 0 then last else $curr - 1 end
    ')

  prev_id=$((prev_id < 1 ? 1 : prev_id))
  hyprctl dispatch movetoworkspace "$prev_id"
}

handle_last() {
  local current_ws=$(hyprctl -j activeworkspace)
  local window_count=$(echo "$current_ws" | jq '.windows')
  [[ $window_count -eq 0 ]] && exit 0

  local workspaces_json=$(hyprctl -j workspaces | jq 'map(select(.id >= 1)) | sort_by(.id)')
  local last_id=$(echo "$workspaces_json" | jq '[.[].id] | max')

  [[ "$last_id" == "null" ]] && exit 0

  hyprctl dispatch movetoworkspace "$last_id"
}

handle_new() {
  local current_ws=$(hyprctl -j activeworkspace)
  local current_id=$(echo "$current_ws" | jq '.id')
  local window_count=$(echo "$current_ws" | jq '.windows')

  [[ $window_count -eq 0 ]] && exit 0

  local workspaces_json=$(hyprctl -j workspaces | jq 'map(select(.id >= 1)) | sort_by(.id)')
  local max_id=$(echo "$workspaces_json" | jq '[.[].id] | max // 0')

  if [[ $current_id -eq $max_id ]]; then
    exit 0
  fi

  local next_id=$((max_id + 1))
  hyprctl dispatch movetoworkspace "$next_id"
}

handle_first() {
  local current_ws=$(hyprctl -j activeworkspace)
  local window_count=$(echo "$current_ws" | jq '.windows')
  [[ $window_count -eq 0 ]] && exit 0

  local workspaces_json=$(hyprctl -j workspaces | jq 'map(select(.id >= 1)) | sort_by(.id)')
  local first_id=$(echo "$workspaces_json" | jq '.[0].id')

  [[ "$first_id" == "null" ]] && exit 0

  hyprctl dispatch movetoworkspace "$first_id"
}

handle_numeric() {
  local position=$1

  local current_ws=$(hyprctl -j activeworkspace)
  local window_count=$(echo "$current_ws" | jq '.windows')
  [[ $window_count -eq 0 ]] && exit 0

  local workspaces_json=$(hyprctl -j workspaces | jq 'map(select(.id >= 1)) | sort_by(.id)')
  local count=$(echo "$workspaces_json" | jq 'length')

  if ((position < 1 || position > count)); then
    exit 0
  fi

  local target_id=$(echo "$workspaces_json" | jq -r ".[$((position - 1))].id")
  hyprctl dispatch movetoworkspace "$target_id"
}

case $COMMAND in
"next")
  handle_next
  ;;
"previous")
  handle_previous
  ;;
"new")
  handle_new
  ;;
"last")
  handle_last
  ;;
"first")
  handle_first
  ;;
*)
  if [[ $COMMAND =~ ^[0-9]+$ ]]; then
    handle_numeric "$COMMAND"
  else
    echo "Unknown command: $COMMAND"
    echo "Available commands:"
    echo "  next     - Move window to next workspace"
    echo "  previous - Move window to previous workspace"
    echo "  new      - Move window to new workspace"
    echo "  last     - Move window to last existing workspace"
    echo "  first    - Move window to first workspace"
    echo "  <number> - Move window to workspace at position"
    exit 1
  fi
  ;;
esac
