#!/bin/bash

# :: retrieve a single DTX definition for use with meta
function get_dtx {
  local dtx
  local set_definition=$1

  while read line
  do
    if [[ $line =~ ^#L[0-9]FILE\:\s*(.*)$ ]]; then
      dtx=${BASH_REMATCH[1]}
    fi
  done <<< "$(iconv -f SHIFT-JIS -t UTF-8 "$set_definition")"

  echo "${set_definition/set.def/$dtx}"
}

# :: get all set.def files
find . -type f -name "set.def" -print0 | \
while IFS= read -r -d '' file; do
  get_dtx "$file";
done
