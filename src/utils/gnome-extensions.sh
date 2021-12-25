#!/bin/bash

function install_extension() {
  local gnome_extensions_url="https://extensions.gnome.org/extension-data"
  local ext_name ext_package ext_uuid output_dir

  while [ "$1" != "" ]; do
    case $1 in
    --name)
      shift
      ext_name=$1
      ;;
    --package)
      shift
      ext_package=$1
      ;;
    *)
      printf "Invalid function arguments for ${FUNCNAME[0]}\n"
      exit
      ;;
    esac
    shift
  done

  output_dir=$(basename $ext_package ".zip")

  wget "${gnome_extensions_url}/${ext_package}"

  run_as_user "unzip -q -d ${output_dir} ${ext_package}"
  ext_uuid=$(cat "${output_dir}/metadata.json" | grep uuid | cut -d \" -f4)

  if [[ ! -d ${GNOME_EXTENSIONS_DIR} ]]; then
    run_as_user "mkdir -p ${GNOME_EXTENSIONS_DIR}"
  fi

  run_as_user "mv ${output_dir} ${GNOME_EXTENSIONS_DIR}/${ext_uuid}"

  rm $ext_package
}

##################################################################
# Backup or restore gnome extension settings
# Arguments:
#   --mode - valid values: backup or restore
#   --backup-dir - destination directory for the backup or source
#                  directory when restoring settings
##################################################################
function extension_settings() {
  local valid_modes=(backup restore)
  local is_valid_mode mode backup_dir schema

  while [ "$1" != "" ]; do
    case $1 in
    --mode)
      shift
      mode=$1
      ;;
    --backup-dir)
      shift
      backup_dir=$1
      ;;
    *)
      printf "Invalid function arguments for ${FUNCNAME[0]}\n"
      exit
      ;;
    esac
    shift
  done

  for i in "${!valid_modes[@]}"; do
    if [[ "${valid_modes[$i]}" = "${mode}" ]]; then
      is_valid_mode=true
    fi
  done

  if [[ ! $is_valid_mode ]]; then
    echo "Mode not supported. Please set mode to \"backup\" or \"restore\""
    exit 1
  fi

  for gnome_extension in $(find $GNOME_EXTENSIONS_DIR -mindepth 1 -maxdepth 1 -type d); do
    schema_dir="${gnome_extensions_dir}/schemas"
    if [[ -d $schema_dir ]]; then
      schema_file=$(find $schema_dir -path "*.gschema.xml" -type f)
      schema=""

      if [[ -f $schema_file ]]; then
        # Get settings schema from schema xml file name
        schema=$(basename -s .gschema.xml $schema_file | sed "s/\./\//g")
      else
        # Get settings schema from file metadata.json file
        metadata_file="${gnome_extension}/metadata.json"
        if [[ -f $metadata_file ]]; then
          schema=$(
            grep "\"settings-schema\":" < $metadata_file | sed -e "s/[[:space:]]*//g" \
              -e "s/\".*\":\"//" \
              -e "s/\",//" \
              -e "s/\./\//g"
          )
        fi
      fi

      if [[ -z $schema ]]; then
        continue
      fi

      if [[ $mode = ${valid_modes[0]} ]]; then
        mkdir -p $backup_dir
        dconf dump "/${schema}/" > "${backup_dir}/${gnome_extension}.dconf"
      elif [[ $mode = ${valid_modes[1]} ]]; then
        cat "${backup_dir}/${gnome_extension}.dconf" | dconf load "/${schema}/"
      fi
    fi
  done
}
