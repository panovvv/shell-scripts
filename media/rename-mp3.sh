#!/bin/bash

if [[ -z "$1" ]] || [[ "$1" = "-h" ]] || [[ "$1" = "--help" ]] ;
then
  echo "Usage: $(basename "$0") <directory>"
  echo "	searches for ' - ' substring in file names, automatically sets ID3 tags from what it finds there."
  exit 1
fi

if ! [ -d "$1" ] ;
then 
  echo "Please provide a valid directory!"
  exit 1
fi

if ! [[ -x "$(command -v id3v2)" ]] ;
then
  echo 'This script requires id3v2 to be installed and in PATH'
  exit 1
fi

# Show a line of dashes
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -

fullDirName="$(cd "$(dirname "$1")"; pwd)/$(basename "$1")"
echo "Target directory: \"${fullDirName}\""

countInDir="$(find "$fullDirName" -iname '*.mp3' | wc -l | tr -d '[:space:]')"

# Show a line of dashes
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -

message="Are you sure you want to automatically set ID3 tags for ${countInDir} songs"
message="$message in \"${fullDirName}\"? (y or Y to proceed)`echo $'\n> '`"

read -p "$message" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
  # Show a line of dashes
  printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -

  for i in "${fullDirName}/"*.mp3; do
      WITH_EXT=$(basename "$i")
      WITHOUT_EXT="${WITH_EXT%.*}"
      if echo ${WITHOUT_EXT} | grep -q " - "; then
        ARTIST=$(echo "${WITHOUT_EXT}" | awk -F ' - ' '{print $1}')
        SONG=$(echo "${WITHOUT_EXT}" | awk -F ' - ' '{print $2}')
        echo "Processing $WITH_EXT... Artist: ${ARTIST}, title: ${SONG}"
        id3v2 -a "${ARTIST}" -t "${SONG}" "$i"
      else
        echo "Processing $WITH_EXT... Can't find ' - ' in name!"
      fi
  done

  # Show a line of dashes
  printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
fi

