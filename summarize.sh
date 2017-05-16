#!/bin/bash

function sanitize {
  echo $(echo $1 | sed 's/\r$//')
}

# :: retrieve a single DTX definition for use with meta
function get_dtx {
  local dtx
  local set_definition=$1

  while read line
  do
    if [[ $line =~ ^#L[0-9]FILE\:[[:space:]]*(.*) ]]; then
      dtx=$(sanitize "${BASH_REMATCH[1]}")
    fi
  done <<< "$(iconv -f SHIFT-JIS -t UTF-8 "$set_definition")"

  echo -e "${set_definition/set.def/$dtx}"
}

# :: retrieves relevant song meta from a DTX definition
function get_song_metadata {
  local song_title
  local song_artist
  local song_comments

  local dtx_definition=$1

  while read metaline
  do
    if [[ $metaline =~ ^#TITLE\:[[:space:]]*(.*)$ ]]; then 
      song_title=$(sanitize "${BASH_REMATCH[1]}")
    elif [[ $metaline =~ ^#ARTIST\:[[:space:]]*(.*)$ ]]; then 
      song_artist=$(sanitize "${BASH_REMATCH[1]}")
    elif [[ $metaline =~ ^#COMMENTS\:[[:space:]]*(.*)$ ]]; then
      song_comments=$(sanitize "${BASH_REMATCH[1]}")
    fi
  done <<< "$(iconv -f SHIFT-JIS -t UTF-8 "$1")"

  echo "\"${song_artist}\",\"${song_title}\",\"${song_comments}\""
}

# :: get all set.def files
find . -type f -name "set.def" -print0 | \
while IFS= read -r -d '' file; do
  dtx_file=$(get_dtx "$file");
  get_song_metadata "$dtx_file"
done
