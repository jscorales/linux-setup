#!/bin/bash

declare -g TARGET_USER LOCAL_SHARE_DIR CONFIG_DIR DBEAVER_DATA_DIR

RED="\033[0;31m"
NC="\033[0m" # No Color
GREEN="\033[0;32m"
YELLOW="\033[1;33m"

function is_sudo() {
  if [[ $EUID -ne 0 ]]; then
    echo "This script must be run with sudo (sudo -i)"
    exit 1
  fi
}

# Function to run command as non-root user
function run_as_user() {
  sudo -u $TARGET_USER bash -c "$1"
}

function prompt_target_user() {
  if [[ -n $TARGET_USER ]]; then
    return
  fi

  read -p "Please enter your username: " TARGET_USER

  if id -u $TARGET_USER >/dev/null 2>&1; then
    HOME_DIR="/home/${TARGET_USER}"
    LOCAL_SHARE_DIR="${HOME_DIR}/.local/share"
    CONFIG_DIR="${HOME_DIR}/.config"
    GNOME_EXTENSIONS_DIR="${LOCAL_SHARE_DIR}/gnome-shell/extensions"
    DBEAVER_DATA_DIR="${LOCAL_SHARE_DIR}/DBeaverData/workspace6/General"

    echo "User ${TARGET_USER} exists, proceeding..."
  else
    echo "The username ${TARGET_USER} does not exist."
    exit 1
  fi
}
