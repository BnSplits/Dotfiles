#!/usr/bin/env bash

COMMAND=$1

handle_next() {
  local current_ws=$(hyprctl -j activeworkspace)
  local current_id=$(echo "$current_ws" | jq '.id')
  local window_count=$(echo "$current_ws" | jq '.windows')

  local workspaces_json=$(hyprctl -j workspaces | jq 'map(select(.id >= 1)) | sort_by(.id)')
  local last_id=$(echo "$workspaces_json" | jq '.[-1].id')

  if [[ $window_count -eq 0 ]] && [[ $current_id -eq $last_id ]]; then
    exit 0
  fi

  local next_id=$(echo "$workspaces_json" | jq --argjson curr "$current_id" '
      [.[].id] | 
      map(select(. > $curr)) | 
      if length > 0 then first else $curr + 1 end
  ')

  hyprctl dispatch workspace "$next_id"
}

handle_previous() {
  local current_ws=$(hyprctl -j activeworkspace)
  local current_id=$(echo "$current_ws" | jq '.id')
  local window_count=$(echo "$current_ws" | jq '.windows')

  local workspaces_json=$(hyprctl -j workspaces | jq 'map(select(.id >= 1)) | sort_by(.id)')

  local first_id=$(echo "$workspaces_json" | jq '.[0].id')

  if [[ $current_id -eq $first_id ]]; then
    exit 0
  fi

  local prev_id=$(echo "$workspaces_json" | jq --argjson curr "$current_id" '
    [.[].id] | 
    map(select(. < $curr)) | 
    if length > 0 then last else $curr - 1 end
  ')

  prev_id=$((prev_id < 1 ? 1 : prev_id))
  hyprctl dispatch workspace "$prev_id"
}

handle_last() {
  local current_ws=$(hyprctl -j activeworkspace)
  local current_id=$(echo "$current_ws" | jq '.id')
  local window_count=$(echo "$current_ws" | jq '.windows')

  local workspaces_json=$(hyprctl -j workspaces | jq 'map(select(.id >= 1)) | sort_by(.id)')

  # Determine last workspace ID excluding current if empty
  local last_id=$(echo "$workspaces_json" | jq --argjson curr "$current_id" --argjson wc "$window_count" '
    [.[] | select(if $wc == 0 then .id != $curr else true end)] | 
    if length > 0 then max_by(.id).id else 1 end
  ')

  hyprctl dispatch workspace "$last_id"
}

handle_new() {
  local current_ws=$(hyprctl -j activeworkspace)
  local window_count=$(echo "$current_ws" | jq '.windows')
  [[ $window_count -eq 0 ]] && exit 0

  local workspaces_json=$(hyprctl -j workspaces | jq 'map(select(.id >= 1)) | sort_by(.id)')
  local max_id=$(echo "$workspaces_json" | jq '[.[].id] | max // 0')
  local next_id=$((max_id + 1))

  hyprctl dispatch workspace "$next_id"
}

handle_first() {
  local workspaces_json=$(hyprctl -j workspaces | jq 'map(select(.id >= 1)) | sort_by(.id)')
  local first_id=$(echo "$workspaces_json" | jq '.[0].id')

  # Handle empty workspace list (shouldn't normally happen)
  [[ "$first_id" == "null" ]] && exit 0

  hyprctl dispatch workspace "$first_id"
}

handle_numeric() {
  local position=$1
  local workspaces_json=$(hyprctl -j workspaces | jq 'map(select(.id >= 1)) | sort_by(.id)')
  local count=$(echo "$workspaces_json" | jq 'length')

  # Validate position
  if ((position < 1 || position > count)); then
    exit 0
  fi

  local target_id=$(echo "$workspaces_json" | jq -r ".[$((position - 1))].id")
  hyprctl dispatch workspace "$target_id"
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
    echo "  next     - Switch to next available workspace"
    echo "  previous - Switch to previous available workspace"
    echo "  new      - Create and switch to new workspace"
    echo "  last     - Switch to last existing workspace"
    echo "  first    - Switch to first workspace in list"
    echo "  <number> - Switch to workspace at specified position"
    exit 1
  fi
  ;;
esac
