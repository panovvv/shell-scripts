#!/bin/bash

# For a given folder with pictures in it, creates sub-folders
# named after model of camera each picture was taken and
# moves the images to their corresponding folders.
# Unclassified pictures are moved to a "misc" folder.

sortByCameraModel () {
  folderName="$(exiftool -p '$make $model' -q -f "$1")"
  if [[ ${#folderName} -lt 1 ]]
  then
    echo "Processing \"$(basename "$1")\"... No camera info in EXIF! Moving to /misc"
    mkdir -p "${fullDirName}/misc/"
    mv -vn "$1" "${fullDirName}/misc/"
  else
    echo "Processing \"$(basename "$1")\"... Will move to \"${folderName}\""
    mkdir -p "${fullDirName}/${folderName}/"
    mv -vn "$1" "${fullDirName}/${folderName}/"
  fi
} 

if [[ -z "$1" ]] || [[ "$1" = "-h" ]] || [[ "$1" = "--help" ]] ;
then
  echo "Usage: $(basename "$0") <directory>"
  exit 1
fi

if ! [ -d "$1" ] ;
then 
  echo "Please provide a valid directory!"
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

countInDir="$(find "$fullDirName" -maxdepth 1 \( -iname '*.jpg' -or -iname '*.jpeg' -or -iname '*.raw' -or -iname '*.arw' \) | wc -l | tr -d '[:space:]')"

# Show a line of dashes
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -

message="Are you sure you want to sort ${countInDir} images according"
message="$message to the camera they were taken with in \"${fullDirName}\"?"
message="$message (y or Y to proceed)`echo $'\n> '`"

read -p "$message" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
  export -f sortByCameraModel
  export fullDirName
  # Show a line of dashes
  printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -

  find "${fullDirName}" -maxdepth 1 -type f -iname '*.jpg' -exec bash -c 'sortByCameraModel "$0"' {} \;
  find "${fullDirName}" -maxdepth 1 -type f -iname '*.jpeg' -exec bash -c 'sortByCameraModel "$0"' {} \;
  find "${fullDirName}" -maxdepth 1 -type f -iname '*.raw' -exec bash -c 'sortByCameraModel "$0"' {} \;
  find "${fullDirName}" -maxdepth 1 -type f -iname '*.arw' -exec bash -c 'sortByCameraModel "$0"' {} \;

  # Show a line of dashes
  printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
fi

