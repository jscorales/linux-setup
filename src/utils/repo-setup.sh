#!/bin/bash

. "$(dirname "$0")/utils/common.sh"

keyrings_dir="/usr/share/keyrings"
keyring_suffix="-archive-keyring.gpg"

function __add_repository_key() {
  local key_name key_url

  while [ "$1" != "" ]; do
    case $1 in
    --key-name)
      shift
      key_name=$1
      ;;
    --key-url)
      shift
      key_url=$1
      ;;
    *)
      printf "Invalid function arguments for ${FUNCNAME[0]}\n"
      exit
      ;;
    esac
    shift
  done

  key_filename="${key_name}${keyring_suffix}"
  printf "Adding ${key_name} keyring..."

  if [[ -e "${keyrings_dir}/${key_filename}" ]]; then
    printf "${key_filename} already exists, skipping\n"
    return
  fi

  key_format="gpg"
  eval "curl -fsSLo ${key_filename} ${key_url}"
  if eval "file ${key_filename} | grep -Eo \"Public-Key[[:space:]]\(old\)\" >/dev/null 2>&1"; then
    key_format="asc"
  fi

  if [[ $key_format = "asc" ]]; then
    gpg --dearmor --output "${keyrings_dir}/${key_filename}" "${key_filename}"
    rm "${key_filename}" 2>/dev/null
  else
    mv "${key_filename}" "${keyrings_dir}/${key_filename}"
  fi

  printf "OK\n"
}

function add_apt_repository() {
  local apt_sources_dir="/etc/apt/sources.list.d"
  local repo_name repo_source key_name key_url

  while [ "${1}" != "" ]; do
    case $1 in
    --name)
      shift
      repo_name=$1
      ;;
    --source)
      shift
      repo_source=$1
      ;;
    --key-name)
      shift
      key_name=$1
      ;;
    --key-url)
      shift
      key_url=$1
      ;;
    *)
      printf "Invalid function arguments for ${FUNCNAME[0]}\n"
      exit
      ;;
    esac
    shift
  done

  __add_repository_key \
    --key-name "$key_name" \
    --key-url "$key_url"

  printf "Adding ${repo_name} source... "
  echo "deb [arch=amd64 signed-by=${keyrings_dir}/${key_name}${keyring_suffix}] ${repo_source}" |
    sudo tee "${apt_sources_dir}/${repo_name}.list"
  printf "OK\n"
}
