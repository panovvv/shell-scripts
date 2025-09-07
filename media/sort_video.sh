#!/bin/bash

# For a given folder with videos in it, creates sub-folders
# named after model of camera each video was taken and
# moves the videos to their corresponding folders.
# Unclassified videos are moved to a "misc" folder.

sortByCameraModel () {
  # When camera info present: "Make model"
  # When camera info present: "- -" (hence < 4 characters limit)
  folderName="$(exiftool -p '$majorBrand' -q -f "$1")"
  if [[ ${#folderName} -lt 4 ]]
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

countInDir="$(find "$fullDirName" -maxdepth 1 \( -iname '*.mp4' -or -iname '*.3gp' \) | wc -l | tr -d '[:space:]')"

# Show a line of dashes
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -

message="Are you sure you want to sort ${countInDir} videos according"
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

  find "${fullDirName}" -maxdepth 1 -type f -iname '*.mp4' -exec bash -c 'sortByCameraModel "$0"' {} \;
#   find "${fullDirName}" -maxdepth 1 -type f -iname '*.3gp' -exec bash -c 'sortByCameraModel "$0"' {} \;

  # Show a line of dashes
  printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
fi

