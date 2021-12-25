#!/bin/bash

. "${BASH_SOURCE%/*}/yaml-parser.sh"

# Read config file
eval "$(parse_yaml "./config/config.yaml")"

# Get OS codename
os_codename=$(lsb_release -c | sed -e 's/Codename:[[:space:]]*//')
os_config_dir="./config/${os_codename}"

# Load config for the OS if exists
if [[ -d $os_config_dir ]]; then
  for conf_file in "${os_config_dir}/*.conf"; do
    . $conf_file
  done
fi
