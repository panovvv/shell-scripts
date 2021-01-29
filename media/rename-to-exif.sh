#!/bin/bash

# * Works with JPG files, extension is case-insensitive
# * Thanks to jhead, conflicts because of pictures taken at the same time
#   will be resolved by adding postfix automatically.
# * If EXIF date is empty, the file will be renamed according to
# either creation date, modification date or skipped altogether

FLAG=s

renameMedia () {
  if [[ "$2" = "mp4" ]] ;
  then
    dat="$(exiftool -p '$mediaCreateDate' -q -f "$1" -d %Y-%m-%d_%H-%M-%S)"
  else
    dat="$(exiftool -p '$dateTimeOriginal' -q -f "$1" -d %Y-%m-%d_%H-%M-%S)"
  fi
  if [[ ${#dat} -lt 19 ]]
  then
    case "${FLAG}" in
      c*)	finalName="$(stat -f %SB -t %Y-%m-%d_%H-%M-%S "$1").$2"
        if [[ "${finalName}" = "$(basename "$1")" ]] ;
        then
          echo "Processing \"$(basename "$1")\"... This looks correct! No need to rename it."
        else
          echo "Processing \"$(basename "$1")\"... No DateTimeOriginal found! Will rename to \"${finalName}\""
          mv -vn "$1" "${fullDirName}/${finalName}"
        fi
        ;;
      m*)	finalName="$(date -r "$1" +"%Y-%m-%d_%H-%M-%S").$2"
        if [[ "${finalName}" = "$(basename "$1")" ]] ;
        then
          echo "Processing \"$(basename "$1")\"... This looks correct! No need to rename it."
        else
          echo "Processing \"$(basename "$1")\"... No DateTimeOriginal found! Will rename to \"${finalName}\""
          mv -vn "$1" "${fullDirName}/${finalName}"
        fi
        ;;
      s*)	echo "Processing \"$(basename "$1")\"... No DateTimeOriginal found! Skipping...";;
      *)	echo "Bad FLAG specified!";
        exit 1
    esac
  else
    if [[ "${dat}.$2" = "$(basename "$1")" ]] ;
    then
      echo "Processing \"$(basename "$1")\"... This looks correct! No need to rename it."
    else
      if [[ "$2" = "jpeg" ]] || [[ "$2" = "jpg" ]] ;
      then
        echo "Processing \"$(basename "$1")\"... Will rename to \"${dat}.$2\""
        jhead -n%Y-%m-%d_%H-%M-%S "$1"
      else
        echo "Processing RAW or video \"$(basename "$1")\"... Will rename to \"${dat}.$2\""
        mv -vn "$1" "${fullDirName}/${dat}.$2"
      fi
    fi
  fi
}

if [[ -z "$1" ]] || [[ "$1" = "-h" ]] || [[ "$1" = "--help" ]] ;
then
  echo "Usage: $(basename "$0") <directory> FLAG"
  echo "	where FLAG defines how this script treats images without"
  echo "	DateTimeOriginal. FLAG can be one of the following:"
  echo "		c - set image name based on file creation date"
  echo "		m - set image name based on file modification date"
  echo "		s - skip these images"
  echo "	FLAG is set to s by default."
  exit 1
fi

if ! [ -d "$1" ] ;
then 
  echo "Please provide a valid directory!"
  exit 1
fi

if ! [[ -x "$(command -v jhead)" ]] ;
then
  echo 'This script requires jhead to be installed and in PATH'
  exit 1
fi

if ! [[ -x "$(command -v exiftool)" ]] ;
then
  echo 'This script requires exiftool to be installed and in PATH'
  exit 1
fi

# Show a line of dashes
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -

fullDirName="$(cd "$(dirname "$1")"; pwd)/$(basename "$1")"
echo "Target directory: \"${fullDirName}\""

countInDir="$(find "$fullDirName" \( -iname '*.jpg' -or -iname '*.jpeg' -or -iname '*.raw' -or -iname '*.arw' \) | wc -l | tr -d '[:space:]')"
countInDirVid="$(find "$fullDirName" -iname '*.mp4' | wc -l | tr -d '[:space:]')"

if ! [ -z ${2} ] ;
then 
  echo "Parsing user-provided FLAG..."
  case "${2}" in
    c*)	FLAG=$2;;
    m*)	FLAG=$2;;
    s*)	FLAG=$2;;
    *)	echo "Bad FLAG specified! Defaulting to s (keep old name)"
  esac
fi

case "${FLAG}" in
  c*)		echo "Will set file name to CREATION DATE if no DateTimeOriginal found";;
  m*)		echo "Will set file name to MODIFICATION DATE if no DateTimeOriginal found";;
  s*)		echo "Will KEEP OLD file name if no DateTimeOriginal found";;
  *)		echo "Bad FLAG specified!"; exit 1
esac

# Show a line of dashes
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -

message="Are you sure you want to rename ${countInDir} image(s) and ${countInDirVid} video(s)"
message="$message in \"${fullDirName}\"? (y or Y to proceed)`echo $'\n> '`"

read -p "$message" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
  export -f renameMedia
  export FLAG
  export fullDirName
  # Show a line of dashes
  printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -

  find "${fullDirName}" -type f -iname '*.jpg' -exec bash -c 'renameMedia "$0" jpg' {} \;
  find "${fullDirName}" -type f -iname '*.jpeg' -exec bash -c 'renameMedia "$0" jpeg' {} \;
  find "${fullDirName}" -type f -iname '*.raw' -exec bash -c 'renameMedia "$0" raw' {} \;
  find "${fullDirName}" -type f -iname '*.arw' -exec bash -c 'renameMedia "$0" arw' {} \;
  find "${fullDirName}" -type f -iname '*.mp4' -exec bash -c 'renameMedia "$0" mp4' {} \;

  # Show a line of dashes
  printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
fi

