#!/bin/bash

function parse_yaml() {
  local yaml_file="${1}"
  local prefix="CONFIG_"
  local s
  local w
  local fs

  s='[[:space:]]*'
  w='[a-zA-Z0-9_.-]*'
  fs="$(echo @ | tr @ '~')"

  (
    sed -e '/- [^\"]'"[^\']"'.*: /s|\([ ]*\)- \([[:space:]]*\)|\1-\'$'\n''  \1\2|g' |
    sed -ne '/^--/s|--||g; s|\"|\\\"|g; s/[[:space:]]*$//g;' \
      -e "/#.*[\"\']/!s| #.*||g; /^#/s|#.*||g;" \
      -e "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
      -e "s|^\($s\)\($w\)${s}[:-]$s\(.*\)$s\$|\1$fs\2$fs\3|p" |
    awk -F"$fs" 'BEGIN {
        KEY="";
        SECTION="";
        SECTIONS_MAP[defaul]=1;
      }
      {
        indent = length($1) / 2

        if (length($2) == 0) {
          conj[indent]="+"
        } else {
          conj[indent]=""
        }

        vname[indent] = $2

        if (SECTION != vname[0]) {
          SECTION=vname[0]
          KEY=""
        }

        for (i in vname) {
          if (i > indent) {
            delete vname[i]
          }
        }

        if (length($3) > 0) {
          vn=""

          for (i=0; i<indent; i++) {
            vn=(vn)(vname[i])("_")
          }

          if ($2 == "key") {
            KEY=$3;
          } else {
            if (KEY != "" && SECTION != "") {
              section_map_key="'"$prefix"'" vn $2
              if (SECTIONS_MAP[section_map_key] == "") {
                SECTIONS_MAP[section_map_key] = 1
                printf("declare -Ag %s\n", section_map_key)
              }

              printf("%s%s%s%s=([%s]=\"%s\")\n", "'"$prefix"'", vn, $2, conj[indent-1], KEY, $3);
            } else {
              printf("%s%s%s%s=(\"%s\")\n", "'"$prefix"'", vn, $2, conj[indent-1], $3);
            }
          }
        }
      }' |
    sed -e 's/_=/+=/g' |
    awk 'BEGIN {
        FS="=";
        OFS="="
      }
      /(-|\.).*=/ {
        gsub("-|\\.", "_", $1)
      }
      { print }'
  ) <"$yaml_file"
}
