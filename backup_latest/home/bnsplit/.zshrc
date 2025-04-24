# ========================
# Environment Variables
# ========================
export PATH=$PATH:/home/bnsplit/.spicetify
export EDITOR='nvim'

$HOME/.cargo/env

# pnpm
export PNPM_HOME="/home/bnsplit/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end


# ========================
# Zinit Plugin Manager
# ========================
# Initialize zinit
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# ========================
# Plugin Configuration
# ========================
# Load plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Load OMZ snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo

# Completion system setup
fpath+=('/usr/share/zsh/site-functions')
autoload -U compinit && compinit
zinit cdreplay -q  # Replay compdefs

# ========================
# Keybindings
# ========================
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# ========================
# History Configuration
# ========================
HISTSIZE=100000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_find_no_dups

# ========================
# Completion Styling
# ========================
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preiew 'lsd --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'lsd --color $realpath'

# ========================
# Aliases
# ========================
alias l='lsd'
alias ls='lsd'
alias ll='lsd -l'
alias la='lsd -a'
alias lal='lsd -al'
alias lla='lsd -la'
alias sv='sudo vim'
alias snv='sudo nvim'
alias z='clear && zsh'
alias b='clear && bash'
alias n='nvim'
alias c='clear'
alias cf='clear && fastfetch --logo opensuse-tumbleweed_old --logo-padding-top 2'
alias cft='clear && fastfetch --logo opensuse-tumbleweed_old --logo-padding-top 2'
alias cfb='clear && fastfetch --kitty-icat Pictures/Logos/logo2.png --logo-padding-top 0'
alias ccc='colorscript'
alias cd..='cd ..'
alias cd-='cd -'
alias nz='nvim ~/.zshrc'
alias fa='clear && fastfetch --logo arch_small'
alias fl='clear && fastfetch | lolcat'
alias grep='grep --color=always'
alias yo='yay -Rns $(yay -Qdtq)'
alias yu='yay -Syu --noconfirm'
alias rmdb='sudo rm /var/lib/pacman/db.lck'
alias rmrf='rm -rf'
alias nsave='nvim ~/.config/bnsplit/scripts/save.sh'
alias tka='tmux kill-session'
alias tkm='tmux kill-session -t main'
alias tm='$HOME/.config/bnsplit/scripts/tmux_launch_main.sh'
alias colorscript='$HOME/.config/bnsplit/scripts/shell-color-scripts/colorscript'
alias ga='git add .'
alias gc='git commit -m'
alias gp='git push'
alias gP='git pull'

# ========================
# Custom Functions
# ========================

# Clear screen and show crunch colorscript
C() {
  clear &&
  colorscript -e bn-crunchbang | lolcat
}

# Enhanced dd command with progress
ddd() {
  sudo dd bs=4M conv=fsync oflag=direct status=progress if="$1" of="$2"
}

# Download with 16 connections using aria2c
aria16() {
  aria2c -x 16 "$1"
}

# Fuzzy find zsh History
hs() {
  cat ~/.zsh_history | fzf
}

# Save current configuration
save() {
  sudo $HOME/.config/bnsplit/scripts/save.sh
}

# DBUS deactivation
dbus-deactivation() {
  $HOME/.config/bnsplit/scripts/dbus_deactivate.sh
}

# Manage AnimeDive application
AnimeDive() {
  old_dir=$(pwd)
  cd ~/dev/AnimeDive/
  source ./launch-docker.sh
  cd "$old_dir"
}

# Clean neovim swap files
nvc() {
  SWAP_DIR="$HOME/.local/state/nvim/swap"

  if [[ -d "$SWAP_DIR" ]]; then
    rm -r "$SWAP_DIR"
    echo "Neovim swap directory removed: $SWAP_DIR"
  else
    echo "Neovim swap directory does not exist: $SWAP_DIR"
  fi
}

# Create temp bash script
tmp_script() {
  local ext=$1
  local env=$2
  local c=0
  while true; do
    if [[ -n $1 ]]; then
      local file="/tmp/tmpscript$c.$1"
    else
      local file="/tmp/tmpscript$c.sh"
    fi
    if [[ -f "$file" ]]; then
      c=$((c+1))
      continue
    fi
    touch "$file"
    chmod +x "$file"
    echo "#!/usr/bin/env $env" > "$file"
    cd /tmp
    nvim "$file"
    break
  done
}

# Wallhaven wallpaper downloader
wallhaven(){
  "$HOME/.config/bnsplit/scripts/wallhaven.sh" categories=110 purity=100 ratios=landscape sorting=date_added page=1-2 "$@"
}
wallhaven-anime(){
  "$HOME/.config/bnsplit/scripts/wallhaven.sh" categories=010 purity=100 ratios=landscape sorting=date_added page=1-2 "$@"
}
wallhaven-random(){
  "$HOME/.config/bnsplit/scripts/wallhaven.sh" categories=110 purity=100 ratios=landscape sorting=random page=1-2 "$@"
}
wallhaven-anime-random(){
  "$HOME/.config/bnsplit/scripts/wallhaven.sh" categories=010 purity=100 ratios=landscape sorting=random page=1-2 "$@"
}

# Gsettings alias
pap-icon() {
  PAPIRUS_ICON_NAME=$1
  gsettings set org.gnome.desktop.interface icon-theme "Papirus-$PAPIRUS_ICON_NAME-Dark"
  folders=("folder-code.svg" "folder-visiting.svg" "folder-applications.svg" "folder-public.svg" "folder-development.svg" "folder-recent.svg" "folder-steam.svg" "folder-kde.svg" "folder-vmware.svg" "folder-cd.svg" "folder-backup.svg")
  for dir in ~/.icons/Papirus-Dark/*/places/; do
    for folder in "${folders[@]}"; do
      rm -f "$dir/$folder"
      ln -s "$HOME/.icons/Papirus-$PAPIRUS_ICON_NAME-Dark/32x32/places/$folder" "$dir/$folder"
    done
  done
}

# Yazi file manager integration
y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

# Randomize filenames for all files in the current directory
randomize_filenames() {
  echo -n "Do you want to randomize filenames? (Y/n): "
  read choice
  choice=${choice:-Y}
  if [[ "$choice" =~ ^[Yy]$ ]]; then
    for file in *; do
      [[ -f "$file" ]] || continue
      new_name=$(head /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c 16)
      mv -- "$file" "$new_name"
    done
    echo "Files renamed successfully!"
  else
    echo "Operation canceled."
  fi
}

# Rename files sequentially based on their last modified date
rename_sequentially() {
  echo -n "Do you want to rename files sequentially based on their last modified date? (Y/n): "
  read choice
  choice=${choice:-Y}

  if [[ "$choice" =~ ^[Yy]$ ]]; then
    files=($(ls -tr | grep -v '/'))
    total_files=${#files[@]}
    num_digits=$(printf "%d" $total_files | wc -c)
    num_digits=$((num_digits > 2 ? num_digits : 3))

    count=1
    for file in "${files[@]}"; do
      [[ -f "$file" ]] || continue
      new_name=$(printf "%0${num_digits}d" $count)
      mv -- "$file" "$new_name"
      ((count++))
    done
    echo "Files renamed sequentially based on their last modified date!"
  else
    echo "Operation canceled."
  fi
}

# Rename files based on their MIME type (file extensions)
rename_files_by_mime_type() {
  echo -n "Do you want to rename files based on MIME type? (Y/n): "
  read choice
  choice=${choice:-Y}
  if [[ "$choice" =~ ^[Yy]$ ]]; then
    for file in *; do
      [[ -f "$file" ]] || continue
      mime_type=$(file --mime-type -b "$file")
      case "$mime_type" in
        image/jpeg) extension="jpg" ;;
        image/png) extension="png" ;;
        image/gif) extension="gif" ;;
        text/plain) extension="txt" ;;
        application/pdf) extension="pdf" ;;
        *) extension="unknown" ;;
      esac
      mv -- "$file" "${file%.*}.$extension"
    done
    echo "Files renamed with correct extensions!"
  else
    echo "Operation canceled."
  fi
}

# Reload GTK theme
reload_gtk_theme() {
  theme=$(gsettings get org.gnome.desktop.interface gtk-theme)
  gsettings set org.gnome.desktop.interface gtk-theme ''
  sleep 1
  gsettings set org.gnome.desktop.interface gtk-theme $theme
}

# Set random Gruvbox SDDM wallpaper
sddm_random_wall() {
  local source_dir="/home/bnsplit/Pictures/SDDM"
  local dest="/usr/share/sddm/themes/bnsplit-gruv/backgrounds/background"
  local resolved_source dest_dir files random_file

  resolved_source=$(readlink -f "$source_dir" || echo "$source_dir")
  [[ ! -d "$resolved_source" ]] && echo "Error: Source directory not found" >&2 && return 1

  dest_dir=$(dirname "$dest")
  [[ ! -d "$dest_dir" ]] && echo "Error: Destination directory not found" >&2 && return 1

  files=("${resolved_source}"/*(.))
  [[ ${#files[@]} -eq 0 ]] && echo "Error: No images found" >&2 && return 1

  random_file=${files[$((RANDOM % ${#files[@]} + 1))]}
  sudo cp -f "$random_file" "$dest" && echo "SDDM wallpaper updated: ${random_file:t}"
}

# Interactive SDDM wallpaper selection
sddm_choose_wall() {
  local source_dir="/home/bnsplit/Pictures/SDDM"
  local dest="/usr/share/sddm/themes/bnsplit-gruv/backgrounds/background"
  local resolved_source selected_file

  # Use argument as source image if provided
  if [[ $# -gt 0 ]]; then
    selected_file=$(readlink -e "$1")
    if [[ -f "$selected_file" ]]; then
      sudo cp -f "$selected_file" "$dest" && echo "New background: ${selected_file:t}"
      return $?
    else
      echo "Error: File not found: $1" >&2
      return 1
    fi
  fi

  # Original directory selection behavior
  resolved_source=$(readlink -e "$source_dir" || echo "$source_dir")
  [[ ! -d "$resolved_source" ]] && echo "Error: Directory not found" >&2 && return 1

  selected_file=$(find -L "$resolved_source" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.png' \) -print0 | \
    fzf --ansi --border --read0 --prompt="  Select SDDM background: " \
    --header=$'󰄛  Preview 󰄛\n↑↓ - Navigate | ↵ - Select | ESC - Cancel')

  [[ -n "$selected_file" ]] && sudo cp -f "$selected_file" "$dest" && echo "New background: ${selected_file:t}"
}

# Pipe with fzf
fp() {
  $@ | fzf --ansi --border
}

# Make files executable
c+x() {
  chmod +x $@
}

# Bakup file/folder
bak() {
  cp $1 $1.bak
}

# Gruvbox factory
gruvbox_factory() {
  local venv="$HOME/.config/bnsplit/scripts/gruvbox-factory/venv/bin/activate"

  if [[ ! -f "$venv" ]]; then
    echo "Virtual environment not found: $venv" >&2
    return 1
  fi

  (
    source "$venv" && gruvbox-factory "$@"
  )
}

# ========================
# Shell Integrations
# ========================
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"
eval "$(starship init zsh)"

# ========================
# Startup Command
# ========================
# cft
# colorscript -e crunch
# # colorscript -e crunchbang-mini
# colorscript -e crunchbang
# colorscript -e bn-crunchbang
# colorscript -e bn-pacman
# colorscript random
# colorscript -e bn-crunchbang | lolcat

